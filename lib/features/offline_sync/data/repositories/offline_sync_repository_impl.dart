import '../../domain/entities/offline_sync_result.dart';
import '../../domain/offline_sync_failure.dart';
import '../../domain/repositories/offline_sync_repository.dart';
import '../data_sources/local/offline_sync_local_data_source.dart';
import '../data_sources/remote/offline_sync_remote_data_source.dart';

class OfflineSyncRepositoryImpl implements OfflineSyncRepository {
  OfflineSyncRepositoryImpl({
    required OfflineSyncLocalDataSource local,
    required OfflineSyncRemoteDataSource remote,
  }) : _local = local,
       _remote = remote;

  final OfflineSyncLocalDataSource _local;
  final OfflineSyncRemoteDataSource _remote;

  @override
  Future<OfflineSyncResult> syncPendingAttendance({
    required String tenantId,
  }) async {
    final pending = await _local.pendingAttendance();
    final forTenant = pending
        .where((row) => row.tenantId == tenantId)
        .toList(growable: false);

    if (forTenant.isEmpty) {
      return _pushOccupancyOnly(tenantId, upsertedCount: 0);
    }

    await _remote.upsertAttendanceLogs(forTenant);
    await _local.markAttendanceSynced(forTenant.map((row) => row.id));

    return _pushOccupancyOnly(tenantId, upsertedCount: forTenant.length);
  }

  Future<OfflineSyncResult> _pushOccupancyOnly(
    String tenantId, {
    required int upsertedCount,
  }) async {
    final occupancy = await _local.cachedOccupancy(tenantId);
    if (occupancy == null) {
      return OfflineSyncResult(upsertedCount: upsertedCount);
    }

    try {
      await _remote.updateGymOccupancy(
        tenantId: tenantId,
        currentOccupancy: occupancy,
      );
      return OfflineSyncResult(
        upsertedCount: upsertedCount,
        occupancyPushed: true,
      );
    } on OfflineSyncOccupancyRlsFailure catch (failure) {
      // Attendance may already be flushed — surface Backend RLS gap only.
      return OfflineSyncResult(
        upsertedCount: upsertedCount,
        occupancyPushed: false,
        occupancyUpdateDenied: true,
        occupancyDenialDetail: failure.message,
      );
    } on OfflineSyncNotConfiguredFailure {
      // No cloud client in this build — leave local queue untouched for occupancy.
      return OfflineSyncResult(upsertedCount: upsertedCount);
    }
  }
}
