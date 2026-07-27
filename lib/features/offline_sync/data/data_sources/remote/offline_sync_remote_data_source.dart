import '../../../domain/entities/pending_attendance.dart';

/// Remote port for attendance upsert + optional occupancy push.
abstract class OfflineSyncRemoteDataSource {
  /// Idempotent bulk upsert on `attendance_logs.id` (no duplicate rows).
  Future<void> upsertAttendanceLogs(List<PendingAttendance> rows);

  /// Pushes Drift-cached occupancy to `gyms.current_occupancy`.
  ///
  /// Throws [OfflineSyncOccupancyRlsFailure] when UPDATE is denied by RLS/GRANT.
  Future<void> updateGymOccupancy({
    required String tenantId,
    required int currentOccupancy,
  });
}
