import '../entities/offline_sync_result.dart';
import '../repositories/offline_sync_repository.dart';

/// Flushes pending offline attendance logs when connectivity returns.
class SyncPendingAttendanceUseCase {
  SyncPendingAttendanceUseCase(this._repository);

  final OfflineSyncRepository _repository;

  Future<OfflineSyncResult> call({required String tenantId}) {
    return _repository.syncPendingAttendance(tenantId: tenantId);
  }
}
