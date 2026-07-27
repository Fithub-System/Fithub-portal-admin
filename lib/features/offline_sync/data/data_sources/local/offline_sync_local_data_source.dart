import 'package:drift/drift.dart';

import '../../../../../core/database/app_database.dart';
import '../../../domain/entities/pending_attendance.dart';

/// Drift local port for pending attendance + gym occupancy cache.
abstract class OfflineSyncLocalDataSource {
  Future<List<PendingAttendance>> pendingAttendance();

  Future<void> markAttendanceSynced(Iterable<String> ids);

  Future<int?> cachedOccupancy(String tenantId);
}

class OfflineSyncDriftLocalDataSource implements OfflineSyncLocalDataSource {
  OfflineSyncDriftLocalDataSource(this._database);

  final AppDatabase _database;

  @override
  Future<List<PendingAttendance>> pendingAttendance() async {
    final rows = await _database.pendingAttendance();
    return rows
        .map(
          (row) => PendingAttendance(
            id: row.id,
            tenantId: row.tenantId,
            athleteId: row.athleteId,
            checkedInAt: row.checkedInAt,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> markAttendanceSynced(Iterable<String> ids) {
    return _database.markAttendanceSynced(ids);
  }

  @override
  Future<int?> cachedOccupancy(String tenantId) async {
    final gym = await _database.gymForTenant(tenantId);
    return gym?.currentOccupancy;
  }
}

/// Test helper: insert a pending row without going through scan validation.
extension OfflineSyncLocalSeed on AppDatabase {
  Future<void> seedPendingAttendance(PendingAttendance row) {
    return enqueueAttendance(
      LocalAttendanceQueueCompanion.insert(
        id: row.id,
        tenantId: row.tenantId,
        athleteId: row.athleteId,
        checkedInAt: row.checkedInAt,
        isSynced: const Value(false),
      ),
    );
  }
}
