import 'package:fithub_portal_admin/core/storage/secure_storage_service.dart';
import 'package:fithub_portal_admin/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:fithub_portal_admin/features/auth/domain/repositories/auth_repository.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

/// Phase 1.1-PA DI — auth only (no Phase 1.2/1.3 wiring changes required).
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
  }

  static AuthRepository get authRepository => getIt<AuthRepository>();
}

/// Backward-compatible alias used by legacy kit entrypoints.
class ServiceLocator {
  Future<void> setup() => InjectionContainer.init();
}
