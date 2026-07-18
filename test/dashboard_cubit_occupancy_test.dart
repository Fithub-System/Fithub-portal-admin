import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fithub_portal_admin/core/database/app_database.dart';
import 'package:fithub_portal_admin/features/dashboard/domain/entities/gym_occupancy.dart';
import 'package:fithub_portal_admin/features/dashboard/domain/repositories/gyms_occupancy_repository.dart';
import 'package:fithub_portal_admin/features/dashboard/presentation/cubit/dashboard_cubit.dart';

class _MockGymsRepo extends Mock implements GymsOccupancyRepository {}

void main() {
  late AppDatabase database;
  late _MockGymsRepo gymsRepo;
  late StreamController<bool> connectivity;
  late StreamController<GymOccupancy> remote;
  const tenantId = '11111111-1111-1111-1111-111111111111';

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    gymsRepo = _MockGymsRepo();
    connectivity = StreamController<bool>.broadcast();
    remote = StreamController<GymOccupancy>.broadcast();

    await database.upsertGymCache(
      LocalGymCacheCompanion.insert(
        tenantId: tenantId,
        name: 'Pulse Downtown',
        currentOccupancy: const Value(42),
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
      database: database,
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

    final cached = await database.gymForTenant(tenantId);
    expect(cached?.currentOccupancy, 55);

    await cubit.close();
  });

  test('keeps Drift occupancy after going offline', () async {
    var online = true;
    final cubit = DashboardCubit(
      database: database,
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
}
