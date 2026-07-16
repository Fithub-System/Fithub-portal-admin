import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:get_it/get_it.dart';

import 'core/crypto/qr_signature_validator.dart';
import 'core/database/app_database.dart';
import 'core/network/api_provider.dart';
import 'core/network/connectivity_service.dart';
import 'features/scan/data/repositories/scan_repository.dart';

final GetIt getIt = GetIt.instance;

class ServiceLocator {
  Future<void> setup() async {
    getIt.registerFactory(() => Dio());
    getIt.registerFactory(() => ApiProvider(getIt()));

    final database = AppDatabase();
    getIt.registerSingleton<AppDatabase>(database);

    getIt.registerSingleton<ConnectivityService>(ConnectivityService());
    getIt.registerSingleton<QrSignatureValidator>(
      const QrSignatureValidator(),
    );
    getIt.registerSingleton<ScanRepository>(
      ScanRepository(database: database),
    );

    const tenantId = '11111111-1111-1111-1111-111111111111';
    getIt.registerSingleton<String>(tenantId, instanceName: 'tenantId');

    await _seedDemoData(database, tenantId);
  }

  Future<void> _seedDemoData(AppDatabase database, String tenantId) async {
    await database.upsertGymCache(
      LocalGymCacheCompanion.insert(
        tenantId: tenantId,
        name: 'Pulse Downtown',
        currentOccupancy: const Value(42),
        capacityLimit: 120,
      ),
    );

    await database.into(database.localMembers).insertOnConflictUpdate(
          LocalMembersCompanion.insert(
            id: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
            tenantId: tenantId,
            fullName: 'Sara Al-Fares',
            avatarUrl: const Value(null),
            powerScore: const Value(780),
            cryptoSalt: 'demo-salt-001',
            createdAt: DateTime.utc(2026, 1, 1),
          ),
        );
  }
}
