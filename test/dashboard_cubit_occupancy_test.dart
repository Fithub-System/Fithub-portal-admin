import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fithub_portal_admin/core/database/app_database.dart';
import 'package:fithub_portal_admin/features/dashboard/data/datasources/gyms_occupancy_drift_local_data_source.dart';
import 'package:fithub_portal_admin/features/dashboard/data/datasources/gyms_occupancy_local_data_source.dart';
import 'package:fithub_portal_admin/features/dashboard/domain/entities/gym_occupancy.dart';
import 'package:fithub_portal_admin/features/dashboard/domain/repositories/gyms_occupancy_repository.dart';
import 'package:fithub_portal_admin/features/dashboard/presentation/cubit/dashboard_cubit.dart';

class _MockGymsRepo extends Mock implements GymsOccupancyRepository {}

void main() {
  late AppDatabase database;
  late GymsOccupancyLocalDataSource local;
  late _MockGymsRepo gymsRepo;
  late StreamController<bool> connectivity;
  late StreamController<GymOccupancy> remote;
  const tenantId = '11111111-1111-1111-1111-111111111111';

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    local = GymsOccupancyDriftLocalDataSource(database);
    gymsRepo = _MockGymsRepo();
    connectivity = StreamController<bool>.broadcast();
    remote = StreamController<GymOccupancy>.broadcast();

    await local.writeCache(
      const GymOccupancy(
        id: tenantId,
        name: 'Pulse Downtown',
        currentOccupancy: 42,
        capacityLimit: 120,
      ),
    );

    when(() => gymsRepo.fetchOccupancy(tenantId)).thenAnswer(
      (_) async => const GymOccupancy(
        id: tenantId,
        name: 'Pulse Downtown',
        currentOccupancy: 42,
        capacityLimit: 120,
      ),
    );
    when(
      () => gymsRepo.watchOccupancy(tenantId),
    ).thenAnswer((_) => remote.stream);
  });

  tearDown(() async {
    await remote.close();
    await connectivity.close();
    await database.close();
  });

  DashboardCubit buildCubit({required bool online}) {
    return DashboardCubit(
      local: local,
      gymsRepository: gymsRepo,
      tenantId: tenantId,
      isOnline: () => online,
      onConnectivityChanged: connectivity.stream,
    );
  }

  test('loads occupancy from Drift cache when offline', () async {
    final cubit = buildCubit(online: false);
    await cubit.start();

    expect(cubit.state.currentOccupancy, 42);
    expect(cubit.state.capacityLimit, 120);
    expect(cubit.state.gymName, 'Pulse Downtown');
    expect(cubit.state.source, OccupancySource.cache);
    verifyNever(() => gymsRepo.watchOccupancy(any()));

    await cubit.close();
  });

  test('updates occupancy when remote stream emits', () async {
    final cubit = buildCubit(online: true);
    await cubit.start();

    remote.add(
      const GymOccupancy(
        id: tenantId,
        name: 'Pulse Downtown',
        currentOccupancy: 55,
        capacityLimit: 120,
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(cubit.state.currentOccupancy, 55);
    expect(cubit.state.capacityLimit, 120);
    expect(cubit.state.source, OccupancySource.remote);

    final cached = await local.readCached(tenantId);
    expect(cached?.currentOccupancy, 55);

    await cubit.close();
  });

  test('keeps Drift occupancy after going offline', () async {
    var online = true;
    final cubit = DashboardCubit(
      local: local,
      gymsRepository: gymsRepo,
      tenantId: tenantId,
      isOnline: () => online,
      onConnectivityChanged: connectivity.stream,
    );

    await cubit.start();
    remote.add(
      const GymOccupancy(
        id: tenantId,
        name: 'Pulse Downtown',
        currentOccupancy: 60,
        capacityLimit: 120,
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(cubit.state.currentOccupancy, 60);

    online = false;
    connectivity.add(false);
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(cubit.state.currentOccupancy, 60);
    expect(cubit.state.source, OccupancySource.cache);

    await cubit.close();
  });

  test(
    'soft-fallback status when realtime stream errors after one-shot',
    () async {
      final cubit = buildCubit(online: true);
      await cubit.start();
      expect(cubit.state.currentOccupancy, 42);

      remote.addError(StateError('channel closed'));
      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(
        cubit.state.statusMessageKey,
        'dashboard.status.realtime_degraded',
      );
      expect(cubit.state.currentOccupancy, 42);

      await cubit.close();
    },
  );
}
