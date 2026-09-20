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
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.addColumn(localMembers, localMembers.membershipStatus);
        await m.addColumn(localMembers, localMembers.membershipPlanName);
        await m.addColumn(localMembers, localMembers.membershipEndsAt);
      }
      if (from < 3) {
        await m.addColumn(localMembers, localMembers.membershipId);
        await m.addColumn(localMembers, localMembers.membershipPlanId);
      }
      if (from < 4) {
        await m.addColumn(
          localAttendanceQueue,
          localAttendanceQueue.checkedOutAt,
        );
      }
      if (from < 5) {
        await m.addColumn(localMembers, localMembers.publicCode);
        await m.addColumn(localMembers, localMembers.assignedCoachId);
        await m.addColumn(localGymCache, localGymCache.scannerInputMode);
        await m.addColumn(localAttendanceQueue, localAttendanceQueue.scannedVia);
      }
    },
  );

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

  Future<List<LocalMember>> listMembersForTenant(String tenantId) {
    return (select(localMembers)
          ..where((m) => m.tenantId.equals(tenantId))
          ..orderBy([(m) => OrderingTerm.asc(m.fullName)]))
        .get();
  }

  Future<void> enqueueAttendance(LocalAttendanceQueueCompanion entry) {
    return into(localAttendanceQueue).insert(entry);
  }

  /// Open visit for this athlete (checked_out_at IS NULL).
  Future<LocalAttendanceQueueItem?> openVisit({
    required String tenantId,
    required String athleteId,
  }) {
    return (select(localAttendanceQueue)..where(
          (q) =>
              q.tenantId.equals(tenantId) &
              q.athleteId.equals(athleteId) &
              q.checkedOutAt.isNull(),
        ))
        .getSingleOrNull();
  }

  Future<void> checkoutVisit({
    required String visitId,
    required DateTime checkedOutAt,
    bool isSynced = false,
  }) {
    return (update(
      localAttendanceQueue,
    )..where((q) => q.id.equals(visitId))).write(
      LocalAttendanceQueueCompanion(
        checkedOutAt: Value(checkedOutAt),
        isSynced: Value(isSynced),
      ),
    );
  }

  /// True if any local queue row exists for this athlete/tenant on the UTC day
  /// of [day] (legacy helper — FEAT-92 toggle uses [openVisit] instead).
  Future<bool> hasAttendanceOnUtcDay({
    required String tenantId,
    required String athleteId,
    required DateTime day,
  }) async {
    final dayStart = DateTime.utc(day.year, day.month, day.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    final row =
        await (select(localAttendanceQueue)..where(
              (q) =>
                  q.tenantId.equals(tenantId) &
                  q.athleteId.equals(athleteId) &
                  q.checkedInAt.isBiggerOrEqualValue(dayStart) &
                  q.checkedInAt.isSmallerThanValue(dayEnd),
            ))
            .getSingleOrNull();
    return row != null;
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

  Future<int> incrementOccupancy(String tenantId) {
    return applyOccupancyDelta(tenantId, 1);
  }

  Future<int> applyOccupancyDelta(String tenantId, int delta) async {
    final gym = await gymForTenant(tenantId);
    if (gym == null) {
      return 0;
    }
    final next = gym.currentOccupancy + delta;
    return setOccupancy(tenantId, next);
  }

  Future<int> setOccupancy(String tenantId, int occupancy) async {
    final gym = await gymForTenant(tenantId);
    if (gym == null) {
      return 0;
    }
    final next = occupancy < 0 ? 0 : occupancy;
    await (update(localGymCache)..where((g) => g.tenantId.equals(tenantId)))
        .write(LocalGymCacheCompanion(currentOccupancy: Value(next)));
    return next;
  }

  Future<void> upsertMembers(List<LocalMembersCompanion> members) async {
    if (members.isEmpty) return;
    await batch((batch) {
      for (final member in members) {
        batch.insert(localMembers, member, mode: InsertMode.insertOrReplace);
      }
    });
  }
}
