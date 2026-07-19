import 'package:get_it/get_it.dart';

import '../../core/network/connectivity_service.dart';

/// Connectivity feature DI.
void registerConnectivityDependencies(GetIt getIt) {
  if (!getIt.isRegistered<ConnectivityService>()) {
    getIt.registerLazySingleton<ConnectivityService>(ConnectivityService.new);
  }
}
