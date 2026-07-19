import '../entities/offline_sync_result.dart';

/// Port: flush Drift [LocalAttendanceQueue] to cloud on reconnect.
abstract class OfflineSyncRepository {
  /// Bulk idempotent upsert of unsynced rows, then mark local `is_synced`.
  ///
  /// Also attempts gyms `current_occupancy` push from Drift cache.
  Future<OfflineSyncResult> syncPendingAttendance({required String tenantId});
}
