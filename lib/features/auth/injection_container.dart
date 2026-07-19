import 'package:get_it/get_it.dart';

import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import '../../core/storage/secure_storage_service.dart';

/// Auth feature DI (kit per-feature container).
void registerAuthDependencies(GetIt getIt) {
  if (!getIt.isRegistered<SecureStorageService>()) {
    getIt.registerLazySingleton<SecureStorageService>(SecureStorageService.new);
  }
  if (!getIt.isRegistered<AuthRepository>()) {
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(secureStorage: getIt()),
    );
  }
}
