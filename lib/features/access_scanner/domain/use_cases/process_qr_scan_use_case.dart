import '../../../../core/database/app_database.dart';
import '../../../offline_sync/domain/offline_sync_failure.dart';
import '../../../offline_sync/domain/use_cases/offline_sync_use_case.dart';
import '../../../scan/data/data_sources/remote/toggle_gym_attendance_remote_data_source.dart';
import '../../../scan/data/repositories/scan_repository.dart';
import '../entities/member_roster_entry.dart';
import '../repositories/member_roster_repository.dart';

/// QR scan — local Drift first (FEAT-01 AC2). Online path calls
/// `toggle_gym_attendance` (FEAT-92). Offline SafeMode queues upsert.
class ProcessQrScanUseCase {
  const ProcessQrScanUseCase(
    this._scanRepository, {
    SyncPendingAttendanceUseCase? syncPendingAttendance,
    ToggleGymAttendanceRemoteDataSource? toggleAttendance,
    MemberRosterRepository? memberRoster,
  }) : _syncPendingAttendance = syncPendingAttendance,
       _toggleAttendance = toggleAttendance,
       _memberRoster = memberRoster;

  final ScanRepository _scanRepository;
  final SyncPendingAttendanceUseCase? _syncPendingAttendance;
  final ToggleGymAttendanceRemoteDataSource? _toggleAttendance;
  final MemberRosterRepository? _memberRoster;

  /// Mapper placeholder when cloud `crypto_salt` is empty — not a real HMAC key.
  static const placeholderSalt = '00';

  Future<ScanProcessResult> call({
    required String tenantId,
    required String rawPayload,
    bool online = false,
  }) async {
    try {
      return await _run(
        tenantId: tenantId,
        rawPayload: rawPayload,
        online: online,
      );
    } catch (_) {
      return const ScanProcessResult.rejected('Scan failed. Try again.');
    }
  }

  Future<ScanProcessResult> _run({
    required String tenantId,
    required String rawPayload,
    required bool online,
  }) async {
    if (online) {
      final toggle = _toggleAttendance;
      if (toggle != null) {
        final rpcResult = await _tryOnlineToggle(
          tenantId: tenantId,
          rawPayload: rawPayload,
          toggle: toggle,
        );
        if (rpcResult != null) return rpcResult;
      }
    }

    final result = await _scanRepository.processOfflineScan(
      tenantId: tenantId,
      rawPayload: rawPayload,
    );

    if (!result.isApproved || !online) {
      return result;
    }

    final sync = _syncPendingAttendance;
    if (sync == null) {
      return result;
    }

    try {
      await sync(tenantId: tenantId);
    } on OfflineSyncFailure {
      // Local queue retained; OfflineSyncCubit retries on reconnect.
    } catch (_) {
      // Soft: receptionist already approved locally (SafeMode).
    }

    return result;
  }

  Future<ScanProcessResult?> _tryOnlineToggle({
    required String tenantId,
    required String rawPayload,
    required ToggleGymAttendanceRemoteDataSource toggle,
  }) async {
    final resolved = await _resolveSignedMember(
      tenantId: tenantId,
      rawPayload: rawPayload,
    );
    if (resolved.result != null) return resolved.result;
    final member = resolved.member;
    if (member == null) return null;

    try {
      final rpc = await toggle.toggle(member.id);
      return _scanRepository.mirrorCloudToggle(
        tenantId: tenantId,
        member: member,
        rpc: rpc,
        at: DateTime.now().toUtc(),
      );
    } on GymAttendanceToggleFailure catch (e) {
      switch (e.code) {
        case 'at_capacity':
          return const ScanProcessResult.rejected('Gym is at capacity.');
        case 'not_member':
          return const ScanProcessResult.rejected(
            'Athlete is not a member of this gym.',
          );
        case 'not_found':
          return const ScanProcessResult.rejected('Athlete not found.');
        case 'forbidden':
          return const ScanProcessResult.rejected(
            'Staff role cannot check members in.',
          );
        default:
          // Network / malformed RPC — SafeMode local toggle.
          return null;
      }
    } catch (_) {
      return null;
    }
  }

  Future<({ScanProcessResult? result, LocalMember? member})>
  _resolveSignedMember({
    required String tenantId,
    required String rawPayload,
  }) async {
    final athleteId = _scanRepository.decodeAthleteId(rawPayload);
    if (athleteId == null) {
      return (
        result: const ScanProcessResult.rejected('Malformed QR payload.'),
        member: null,
      );
    }

    final drift = await _scanRepository.validateScan(
      tenantId: tenantId,
      rawPayload: rawPayload,
    );
    if (drift.member != null) {
      return drift;
    }
    if (drift.result != null &&
        drift.result!.reason != 'Member not cached locally.') {
      return drift;
    }

    final rosterMember = await _lookupRosterMember(
      tenantId: tenantId,
      athleteId: athleteId,
    );
    if (rosterMember == null) {
      return (
        result: const ScanProcessResult.rejected(
          'Member not in this gym roster. Sync Members and try again.',
        ),
        member: null,
      );
    }
    if (!_hasUsableSalt(rosterMember.cryptoSalt)) {
      return (
        result: const ScanProcessResult.rejected(
          'Member crypto key missing. Re-sync roster.',
        ),
        member: null,
      );
    }

    final validation = _scanRepository.validatePayload(
      rawPayload: rawPayload,
      cryptoSalt: rosterMember.cryptoSalt,
    );
    if (!validation.isValid) {
      return (
        result: ScanProcessResult.rejected(validation.reason ?? 'Invalid QR.'),
        member: null,
      );
    }

    return (result: null, member: _toLocalMember(tenantId, rosterMember));
  }

  Future<MemberRosterEntry?> _lookupRosterMember({
    required String tenantId,
    required String athleteId,
  }) async {
    final roster = _memberRoster;
    if (roster == null) return null;

    MemberRosterEntry? match(List<MemberRosterEntry> members) {
      for (final member in members) {
        if (member.id == athleteId) return member;
      }
      return null;
    }

    try {
      final cached = match(await roster.listCachedMembers(tenantId: tenantId));
      if (cached != null) return cached;
      await roster.syncRoster(tenantId: tenantId);
      return match(await roster.listCachedMembers(tenantId: tenantId));
    } catch (_) {
      return null;
    }
  }

  static bool _hasUsableSalt(String salt) {
    final trimmed = salt.trim();
    return trimmed.isNotEmpty && trimmed != placeholderSalt;
  }

  static LocalMember _toLocalMember(String tenantId, MemberRosterEntry entry) {
    return LocalMember(
      id: entry.id,
      tenantId: tenantId,
      fullName: entry.fullName,
      avatarUrl: entry.avatarUrl,
      powerScore: entry.powerScore,
      cryptoSalt: entry.cryptoSalt,
      createdAt: entry.createdAt,
      membershipId: entry.membershipId,
      membershipPlanId: entry.membershipPlanId,
      membershipStatus: entry.membershipStatus,
      membershipPlanName: entry.membershipPlanName,
      membershipEndsAt: entry.membershipEndsAt,
    );
  }
}
