import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/local_attendance_queue.dart';
import 'tables/local_gym_cache.dart';
import 'tables/local_members.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [LocalMembers, LocalAttendanceQueue, LocalGymCache],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'fithub_portal_admin');
  }

  Future<LocalMember?> findMemberById(String athleteId) {
    return (select(localMembers)..where((m) => m.id.equals(athleteId)))
        .getSingleOrNull();
  }

  Future<void> enqueueAttendance(LocalAttendanceQueueCompanion entry) {
    return into(localAttendanceQueue).insert(entry);
  }

  Future<List<LocalAttendanceQueueItem>> pendingAttendance() {
    return (select(localAttendanceQueue)
          ..where((q) => q.isSynced.equals(false)))
        .get();
  }

  Future<LocalGymCacheEntry?> gymForTenant(String tenantId) {
    return (select(localGymCache)..where((g) => g.tenantId.equals(tenantId)))
        .getSingleOrNull();
  }

  Future<void> upsertGymCache(LocalGymCacheCompanion entry) {
    return into(localGymCache).insertOnConflictUpdate(entry);
  }

  Future<int> incrementOccupancy(String tenantId) async {
    final gym = await gymForTenant(tenantId);
    if (gym == null) {
      return 0;
    }
    final next = gym.currentOccupancy + 1;
    await (update(localGymCache)..where((g) => g.tenantId.equals(tenantId)))
        .write(LocalGymCacheCompanion(currentOccupancy: Value(next)));
    return next;
  }
}
