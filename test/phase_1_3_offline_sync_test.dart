import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fithub_portal_admin/core/database/app_database.dart';
import 'package:fithub_portal_admin/features/offline_sync/data/data_sources/local/offline_sync_local_data_source.dart';
import 'package:fithub_portal_admin/features/offline_sync/data/data_sources/remote/offline_sync_remote_data_source.dart';
import 'package:fithub_portal_admin/features/offline_sync/data/repositories/offline_sync_repository_impl.dart';
import 'package:fithub_portal_admin/features/offline_sync/domain/entities/pending_attendance.dart';
import 'package:fithub_portal_admin/features/offline_sync/domain/offline_sync_failure.dart';
import 'package:fithub_portal_admin/features/offline_sync/domain/use_cases/offline_sync_use_case.dart';
import 'package:fithub_portal_admin/features/offline_sync/presentation/cubit/offline_sync_cubit.dart';
import 'package:fithub_portal_admin/features/offline_sync/presentation/cubit/offline_sync_state.dart';

class _FakeRemote extends Mock implements OfflineSyncRemoteDataSource {}

void main() {
  const tenantId = '11111111-1111-1111-1111-111111111111';
  const athleteId = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
  final checkedInAt = DateTime.utc(2026, 7, 19, 12, 0, 0);

  late AppDatabase database;
  late OfflineSyncDriftLocalDataSource local;
  late _FakeRemote remote;
  late OfflineSyncRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(
      PendingAttendance(
        id: 'fallback',
        tenantId: tenantId,
        athleteId: athleteId,
        checkedInAt: checkedInAt,
      ),
    );
    registerFallbackValue(<PendingAttendance>[]);
  });

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    local = OfflineSyncDriftLocalDataSource(database);
    remote = _FakeRemote();
    repository = OfflineSyncRepositoryImpl(local: local, remote: remote);
  });

  tearDown(() async {
    await database.close();
  });

  PendingAttendance pending({String id = 'log-1'}) {
    return PendingAttendance(
      id: id,
      tenantId: tenantId,
      athleteId: athleteId,
      checkedInAt: checkedInAt,
    );
  }

  group('OfflineSyncRepository', () {
    test('bulk upserts pending rows then marks is_synced locally', () async {
      await database.seedPendingAttendance(pending(id: 'log-a'));
      await database.seedPendingAttendance(pending(id: 'log-b'));
      await database.upsertGymCache(
        LocalGymCacheCompanion.insert(
          tenantId: tenantId,
          name: 'Pulse Downtown',
          currentOccupancy: const Value(44),
          capacityLimit: 120,
        ),
      );

      when(() => remote.upsertAttendanceLogs(any())).thenAnswer((_) async {});
      when(
        () =>
            remote.updateGymOccupancy(tenantId: tenantId, currentOccupancy: 44),
      ).thenAnswer((_) async {});

      final result = await repository.syncPendingAttendance(tenantId: tenantId);

      expect(result.upsertedCount, 2);
      expect(result.occupancyPushed, isTrue);
      expect(await database.pendingAttendance(), isEmpty);

      final verifyRows = verify(
        () => remote.upsertAttendanceLogs(captureAny()),
      ).captured;
      expect(verifyRows, hasLength(1));
      final sent = verifyRows.single as List<PendingAttendance>;
      expect(sent.map((r) => r.id), containsAll(['log-a', 'log-b']));
    });

    test('second sync is idempotent — no re-upsert of synced rows', () async {
      await database.seedPendingAttendance(pending());
      when(() => remote.upsertAttendanceLogs(any())).thenAnswer((_) async {});
      when(
        () => remote.updateGymOccupancy(
          tenantId: any(named: 'tenantId'),
          currentOccupancy: any(named: 'currentOccupancy'),
        ),
      ).thenAnswer((_) async {});

      await repository.syncPendingAttendance(tenantId: tenantId);
      final second = await repository.syncPendingAttendance(tenantId: tenantId);

      expect(second.upsertedCount, 0);
      verify(() => remote.upsertAttendanceLogs(any())).called(1);
    });

    test(
      'gyms occupancy RLS denial reported without rolling back attendance',
      () async {
        await database.seedPendingAttendance(pending());
        when(() => remote.upsertAttendanceLogs(any())).thenAnswer((_) async {});
        when(
          () => remote.updateGymOccupancy(
            tenantId: any(named: 'tenantId'),
            currentOccupancy: any(named: 'currentOccupancy'),
          ),
        ).thenThrow(const OfflineSyncOccupancyRlsFailure('rls-denied'));

        await database.upsertGymCache(
          LocalGymCacheCompanion.insert(
            tenantId: tenantId,
            name: 'Pulse',
            currentOccupancy: const Value(10),
            capacityLimit: 50,
          ),
        );

        final result = await repository.syncPendingAttendance(
          tenantId: tenantId,
        );

        expect(result.upsertedCount, 1);
        expect(result.occupancyUpdateDenied, isTrue);
        expect(result.occupancyDenialDetail, 'rls-denied');
        expect(await database.pendingAttendance(), isEmpty);
      },
    );
  });

  group('OfflineSyncCubit', () {
    test('syncs on reconnect (offline → online)', () async {
      final connectivity = StreamController<bool>.broadcast();
      var online = false;
      final useCase = SyncPendingAttendanceUseCase(repository);

      when(() => remote.upsertAttendanceLogs(any())).thenAnswer((_) async {});
      when(
        () => remote.updateGymOccupancy(
          tenantId: any(named: 'tenantId'),
          currentOccupancy: any(named: 'currentOccupancy'),
        ),
      ).thenAnswer((_) async {});

      await database.seedPendingAttendance(pending());

      final cubit = OfflineSyncCubit(
        syncPendingAttendance: useCase,
        tenantId: tenantId,
        isOnline: () => online,
        onConnectivityChanged: connectivity.stream,
      );
      await cubit.start();
      expect(cubit.state.status, OfflineSyncStatus.idle);

      online = true;
      connectivity.add(true);
      await pumpEventQueue();

      expect(cubit.state.status, OfflineSyncStatus.success);
      expect(cubit.state.upsertedCount, 1);

      await cubit.close();
      await connectivity.close();
    });
  });

  group('AppDatabase.markAttendanceSynced', () {
    test('transactionally flips is_synced for given ids', () async {
      await database.seedPendingAttendance(pending(id: 'a'));
      await database.seedPendingAttendance(pending(id: 'b'));

      await database.markAttendanceSynced(['a']);

      final pendingRows = await database.pendingAttendance();
      expect(pendingRows, hasLength(1));
      expect(pendingRows.single.id, 'b');
    });
  });
}
