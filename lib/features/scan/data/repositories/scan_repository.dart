import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/crypto/qr_signature_validator.dart';
import '../../../../core/database/app_database.dart';
import '../data_sources/remote/toggle_gym_attendance_remote_data_source.dart';

class ScanRepository {
  ScanRepository({
    required AppDatabase database,
    QrSignatureValidator? validator,
    Uuid? uuid,
  }) : _database = database,
       _validator = validator ?? const QrSignatureValidator(),
       _uuid = uuid ?? const Uuid();

  final AppDatabase _database;
  final QrSignatureValidator _validator;
  final Uuid _uuid;

  /// Validates QR, then toggles local visit (FEAT-92).
  ///
  /// Online cloud write is owned by [ProcessQrScanUseCase] via
  /// `toggle_gym_attendance`. Offline SafeMode queues Drift for upsert.
  Future<ScanProcessResult> processOfflineScan({
    required String tenantId,
    required String rawPayload,
    DateTime? now,
  }) async {
    final validated = await validateScan(
      tenantId: tenantId,
      rawPayload: rawPayload,
      now: now,
    );
    if (validated.result != null) return validated.result!;
    return applyLocalToggle(
      tenantId: tenantId,
      member: validated.member!,
      at: now ?? DateTime.now().toUtc(),
    );
  }

  Future<({ScanProcessResult? result, LocalMember? member})> validateScan({
    required String tenantId,
    required String rawPayload,
    DateTime? now,
  }) async {
    final decoded = _decodeAthleteId(rawPayload);
    if (decoded == null) {
      return (
        result: const ScanProcessResult.rejected('Malformed QR payload.'),
        member: null,
      );
    }

    final member = await _database.findMemberById(decoded);
    if (member == null) {
      return (
        result: const ScanProcessResult.rejected('Member not cached locally.'),
        member: null,
      );
    }

    if (member.tenantId != tenantId) {
      return (
        result: const ScanProcessResult.rejected('Tenant mismatch.'),
        member: null,
      );
    }

    final validation = _validator.validate(
      rawPayload: rawPayload,
      cryptoSalt: member.cryptoSalt,
      now: now,
    );

    if (!validation.isValid) {
      return (
        result: ScanProcessResult.rejected(validation.reason ?? 'Invalid QR.'),
        member: null,
      );
    }

    return (result: null, member: member);
  }

  Future<ScanProcessResult> applyLocalToggle({
    required String tenantId,
    required LocalMember member,
    required DateTime at,
  }) async {
    final open = await _database.openVisit(
      tenantId: tenantId,
      athleteId: member.id,
    );
    if (open != null) {
      await _database.checkoutVisit(visitId: open.id, checkedOutAt: at);
      final occupancy = await _database.applyOccupancyDelta(tenantId, -1);
      return ScanProcessResult.approved(
        memberName: member.fullName,
        avatarUrl: member.avatarUrl,
        occupancy: occupancy,
        membershipStatus: member.membershipStatus,
        event: 'CHECK_OUT',
      );
    }

    final gym = await _database.gymForTenant(tenantId);
    if (gym != null && gym.currentOccupancy >= gym.capacityLimit) {
      return const ScanProcessResult.rejected('Gym is at capacity.');
    }

    await _database.enqueueAttendance(
      LocalAttendanceQueueCompanion.insert(
        id: _uuid.v4(),
        tenantId: tenantId,
        athleteId: member.id,
        checkedInAt: at,
        isSynced: const Value(false),
      ),
    );

    final occupancy = await _database.applyOccupancyDelta(tenantId, 1);
    return ScanProcessResult.approved(
      memberName: member.fullName,
      avatarUrl: member.avatarUrl,
      occupancy: occupancy,
      membershipStatus: member.membershipStatus,
      event: 'CHECK_IN',
    );
  }

  Future<ScanProcessResult> mirrorCloudToggle({
    required String tenantId,
    required LocalMember member,
    required GymAttendanceToggleResult rpc,
    required DateTime at,
  }) async {
    if (rpc.isCheckOut) {
      final open = await _database.openVisit(
        tenantId: tenantId,
        athleteId: member.id,
      );
      if (open != null) {
        await _database.checkoutVisit(
          visitId: open.id,
          checkedOutAt: at,
          isSynced: true,
        );
      } else {
        await _database.enqueueAttendance(
          LocalAttendanceQueueCompanion.insert(
            id: rpc.visitId,
            tenantId: tenantId,
            athleteId: member.id,
            checkedInAt: at,
            checkedOutAt: Value(at),
            isSynced: const Value(true),
          ),
        );
      }
    } else {
      await _database.enqueueAttendance(
        LocalAttendanceQueueCompanion.insert(
          id: rpc.visitId,
          tenantId: tenantId,
          athleteId: member.id,
          checkedInAt: at,
          isSynced: const Value(true),
        ),
      );
    }

    final occupancy = await _database.setOccupancy(tenantId, rpc.occupancy);
    return ScanProcessResult.approved(
      memberName: rpc.memberName ?? member.fullName,
      avatarUrl: member.avatarUrl,
      occupancy: occupancy,
      membershipStatus: rpc.membershipStatus ?? member.membershipStatus,
      event: rpc.event,
    );
  }

  Future<LocalMember?> findMember(String athleteId) {
    return _database.findMemberById(athleteId);
  }

  String? decodeAthleteId(String rawPayload) => _decodeAthleteId(rawPayload);

  String? _decodeAthleteId(String rawPayload) {
    try {
      final decoded = jsonDecode(rawPayload);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return decoded['athlete_id'] as String?;
    } on FormatException {
      return null;
    }
  }
}

class ScanProcessResult {
  const ScanProcessResult._({
    required this.isApproved,
    this.memberName,
    this.avatarUrl,
    this.occupancy,
    this.membershipStatus,
    this.reason,
    this.event = 'CHECK_IN',
  });

  const ScanProcessResult.approved({
    required String memberName,
    String? avatarUrl,
    required int occupancy,
    String? membershipStatus,
    String event = 'CHECK_IN',
  }) : this._(
         isApproved: true,
         memberName: memberName,
         avatarUrl: avatarUrl,
         occupancy: occupancy,
         membershipStatus: membershipStatus,
         event: event,
       );

  const ScanProcessResult.rejected(String reason)
    : this._(isApproved: false, reason: reason);

  final bool isApproved;
  final String? memberName;
  final String? avatarUrl;
  final int? occupancy;
  final String? membershipStatus;
  final String? reason;
  final String event;
}
