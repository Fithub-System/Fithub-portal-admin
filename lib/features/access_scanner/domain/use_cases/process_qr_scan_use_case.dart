import '../../../offline_sync/domain/offline_sync_failure.dart';
import '../../../offline_sync/domain/use_cases/offline_sync_use_case.dart';
import '../../../scan/data/repositories/scan_repository.dart';

/// QR scan branch — local Drift first (FEAT-01 AC2), then cloud flush when online.
///
/// Online success must upsert `attendance_logs` so FEAT-09 award triggers fire.
/// Occupancy cloud push alone is not sufficient (P0-A 2026-07-30).
class ProcessQrScanUseCase {
  const ProcessQrScanUseCase(
    this._scanRepository, {
    SyncPendingAttendanceUseCase? syncPendingAttendance,
  }) : _syncPendingAttendance = syncPendingAttendance;

  final ScanRepository _scanRepository;
  final SyncPendingAttendanceUseCase? _syncPendingAttendance;

  Future<ScanProcessResult> call({
    required String tenantId,
    required String rawPayload,
    bool online = false,
  }) async {
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
      // Upserts pending attendance_logs first, then gyms.current_occupancy.
      await sync(tenantId: tenantId);
    } on OfflineSyncFailure {
      // Local queue retained; OfflineSyncCubit retries on reconnect.
    } catch (_) {
      // Soft: receptionist already approved locally (SafeMode).
    }

    return result;
  }
}
