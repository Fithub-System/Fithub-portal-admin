import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/crypto/qr_signature_validator.dart';
import '../../../../core/database/app_database.dart';

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

  Future<ScanProcessResult> processOfflineScan({
    required String tenantId,
    required String rawPayload,
    DateTime? now,
  }) async {
    final decoded = _decodeAthleteId(rawPayload);
    if (decoded == null) {
      return const ScanProcessResult.rejected('Malformed QR payload.');
    }

    final member = await _database.findMemberById(decoded);
    if (member == null) {
      return const ScanProcessResult.rejected('Member not cached locally.');
    }

    if (member.tenantId != tenantId) {
      return const ScanProcessResult.rejected('Tenant mismatch.');
    }

    final validation = _validator.validate(
      rawPayload: rawPayload,
      cryptoSalt: member.cryptoSalt,
      now: now,
    );

    if (!validation.isValid) {
      return ScanProcessResult.rejected(validation.reason ?? 'Invalid QR.');
    }

    final checkedInAt = now ?? DateTime.now().toUtc();
    // Soft reject when local queue already has a same-UTC-day check-in
    // (cloud unique index attendance_logs_one_per_athlete_tenant_utc_day).
    final alreadyToday = await _database.hasAttendanceOnUtcDay(
      tenantId: tenantId,
      athleteId: member.id,
      day: checkedInAt,
    );
    if (alreadyToday) {
      return const ScanProcessResult.rejected(
        'Already checked in today.',
      );
    }

    await _database.enqueueAttendance(
      LocalAttendanceQueueCompanion.insert(
        id: _uuid.v4(),
        tenantId: tenantId,
        athleteId: member.id,
        checkedInAt: checkedInAt,
        isSynced: const Value(false),
      ),
    );

    final occupancy = await _database.incrementOccupancy(tenantId);
    return ScanProcessResult.approved(
      memberName: member.fullName,
      avatarUrl: member.avatarUrl,
      occupancy: occupancy,
      membershipStatus: member.membershipStatus,
    );
  }

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
  });

  const ScanProcessResult.approved({
    required String memberName,
    String? avatarUrl,
    required int occupancy,
    String? membershipStatus,
  }) : this._(
         isApproved: true,
         memberName: memberName,
         avatarUrl: avatarUrl,
         occupancy: occupancy,
         membershipStatus: membershipStatus,
       );

  const ScanProcessResult.rejected(String reason)
    : this._(isApproved: false, reason: reason);

  final bool isApproved;
  final String? memberName;
  final String? avatarUrl;
  final int? occupancy;
  final String? membershipStatus;
  final String? reason;
}
