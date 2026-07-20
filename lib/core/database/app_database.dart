import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/local_attendance_queue.dart';
import 'tables/local_gym_cache.dart';
import 'tables/local_members.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [LocalMembers, LocalAttendanceQueue, LocalGymCache])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'fithub_portal_admin',
      // Required on Flutter web (Wasm + shared worker). Ignored on native.
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }

  Future<LocalMember?> findMemberById(String athleteId) {
    return (select(
      localMembers,
    )..where((m) => m.id.equals(athleteId))).getSingleOrNull();
  }

  Future<int> countMembersForTenant(String tenantId) async {
    final countExp = localMembers.id.count();
    final query = selectOnly(localMembers)
      ..addColumns([countExp])
      ..where(localMembers.tenantId.equals(tenantId));
    final row = await query.getSingle();
    return row.read(countExp) ?? 0;
  }

  Future<void> enqueueAttendance(LocalAttendanceQueueCompanion entry) {
    return into(localAttendanceQueue).insert(entry);
  }

  Future<List<LocalAttendanceQueueItem>> pendingAttendance() {
    return (select(
      localAttendanceQueue,
    )..where((q) => q.isSynced.equals(false))).get();
  }

  /// Marks queued rows synced after a successful cloud upsert (idempotent).
  Future<void> markAttendanceSynced(Iterable<String> ids) async {
    final idList = ids.toList(growable: false);
    if (idList.isEmpty) return;

    await transaction(() async {
      await (update(localAttendanceQueue)..where((q) => q.id.isIn(idList)))
          .write(const LocalAttendanceQueueCompanion(isSynced: Value(true)));
    });
  }

  Future<LocalGymCacheEntry?> gymForTenant(String tenantId) {
    return (select(
      localGymCache,
    )..where((g) => g.tenantId.equals(tenantId))).getSingleOrNull();
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

  Future<void> upsertMembers(List<LocalMembersCompanion> members) async {
    if (members.isEmpty) return;
    await batch((batch) {
      for (final member in members) {
        batch.insert(
          localMembers,
          member,
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }
}
