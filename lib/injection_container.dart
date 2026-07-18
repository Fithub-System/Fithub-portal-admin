import 'package:fithub_portal_admin/core/database/app_database.dart';
import 'package:fithub_portal_admin/core/network/connectivity_service.dart';
import 'package:fithub_portal_admin/core/storage/secure_storage_service.dart';
import 'package:fithub_portal_admin/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:fithub_portal_admin/features/auth/domain/repositories/auth_repository.dart';
import 'package:fithub_portal_admin/features/dashboard/data/repositories/gyms_occupancy_repository_impl.dart';
import 'package:fithub_portal_admin/features/dashboard/domain/repositories/gyms_occupancy_repository.dart';
import 'package:fithub_portal_admin/features/scan/data/repositories/scan_repository.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

/// Phase 1.1 auth + Phase 1.2 occupancy / connectivity DI.
class InjectionContainer {
  static Future<void> init() async {
    if (!getIt.isRegistered<SecureStorageService>()) {
      getIt.registerLazySingleton<SecureStorageService>(
        SecureStorageService.new,
      );
    }
    if (!getIt.isRegistered<AuthRepository>()) {
      getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(secureStorage: getIt()),
      );
    }
    if (!getIt.isRegistered<AppDatabase>()) {
      getIt.registerLazySingleton<AppDatabase>(AppDatabase.new);
    }
    if (!getIt.isRegistered<ConnectivityService>()) {
      getIt.registerLazySingleton<ConnectivityService>(ConnectivityService.new);
    }
    if (!getIt.isRegistered<GymsOccupancyRepository>()) {
      getIt.registerLazySingleton<GymsOccupancyRepository>(
        GymsOccupancyRepositoryImpl.new,
      );
    }
    if (!getIt.isRegistered<ScanRepository>()) {
      getIt.registerLazySingleton<ScanRepository>(
        () => ScanRepository(database: getIt()),
      );
    }
  }

  static AuthRepository get authRepository => getIt<AuthRepository>();

  static AppDatabase get database => getIt<AppDatabase>();

  static ConnectivityService get connectivityService =>
      getIt<ConnectivityService>();

  static GymsOccupancyRepository get gymsOccupancyRepository =>
      getIt<GymsOccupancyRepository>();

  static ScanRepository get scanRepository => getIt<ScanRepository>();
}

/// Backward-compatible alias used by legacy kit entrypoints.
class ServiceLocator {
  Future<void> setup() => InjectionContainer.init();
}
