import 'package:get_it/get_it.dart';

import '../../core/network/cloud_mutation_guard.dart';
import '../../core/network/connectivity_service.dart';
import 'presentation/cubit/connectivity_cubit.dart';

/// Connectivity feature DI.
void registerConnectivityDependencies(GetIt getIt) {
  if (!getIt.isRegistered<ConnectivityService>()) {
    getIt.registerLazySingleton<ConnectivityService>(ConnectivityService.new);
  }

  if (!getIt.isRegistered<CloudMutationGuard>()) {
    getIt.registerLazySingleton<CloudMutationGuard>(
      () => CloudMutationGuard(
        isOnline: () => getIt<ConnectivityService>().isOnline,
      ),
    );
  }

  if (!getIt.isRegistered<ConnectivityCubit>()) {
    getIt.registerFactory(
      () => ConnectivityCubit(getIt<ConnectivityService>()),
    );
  }
}
