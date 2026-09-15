import '../../../offline_sync/domain/offline_sync_failure.dart';
import '../../../offline_sync/domain/use_cases/offline_sync_use_case.dart';
import '../../../scan/data/data_sources/remote/toggle_gym_attendance_remote_data_source.dart';
import '../../../scan/data/repositories/scan_repository.dart';

/// QR scan — local Drift first (FEAT-01 AC2). Online path calls
/// `toggle_gym_attendance` (FEAT-92). Offline SafeMode queues upsert.
class ProcessQrScanUseCase {
  const ProcessQrScanUseCase(
    this._scanRepository, {
    SyncPendingAttendanceUseCase? syncPendingAttendance,
    ToggleGymAttendanceRemoteDataSource? toggleAttendance,
  }) : _syncPendingAttendance = syncPendingAttendance,
       _toggleAttendance = toggleAttendance;

  final ScanRepository _scanRepository;
  final SyncPendingAttendanceUseCase? _syncPendingAttendance;
  final ToggleGymAttendanceRemoteDataSource? _toggleAttendance;

  Future<ScanProcessResult> call({
    required String tenantId,
    required String rawPayload,
    bool online = false,
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
    final validated = await _scanRepository.validateScan(
      tenantId: tenantId,
      rawPayload: rawPayload,
    );
    if (validated.result != null) return validated.result;
    final member = validated.member;
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
}
