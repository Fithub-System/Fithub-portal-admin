import 'package:get_it/get_it.dart';

import '../../core/network/api_provider.dart';
import '../../core/network/occupancy_backend.dart';
import '../../core/database/app_database.dart';
import 'data/datasources/gyms_occupancy_drift_local_data_source.dart';
import 'data/datasources/gyms_occupancy_http_remote_data_source.dart';
import 'data/datasources/gyms_occupancy_local_data_source.dart';
import 'data/datasources/gyms_occupancy_remote_data_source.dart';
import 'data/datasources/gyms_occupancy_supabase_remote_data_source.dart';
import 'data/repositories/gyms_occupancy_repository_impl.dart';
import 'domain/repositories/gyms_occupancy_repository.dart';

/// Dashboard feature DI (FEAT-04 AC-C5).
void registerDashboardDependencies(GetIt getIt) {
  if (!getIt.isRegistered<GymsOccupancyLocalDataSource>()) {
    getIt.registerLazySingleton<GymsOccupancyLocalDataSource>(
      () => GymsOccupancyDriftLocalDataSource(getIt<AppDatabase>()),
    );
  }

  if (!getIt.isRegistered<GymsOccupancyRemoteDataSource>()) {
    getIt.registerLazySingleton<GymsOccupancyRemoteDataSource>(() {
      if (OccupancyBackendConfig.isHttp) {
        return GymsOccupancyHttpRemoteDataSource(getIt<ApiProvider>());
      }
      return GymsOccupancySupabaseRemoteDataSource();
    });
  }

  if (!getIt.isRegistered<GymsOccupancyRepository>()) {
    getIt.registerLazySingleton<GymsOccupancyRepository>(
      () => GymsOccupancyRepositoryImpl(remote: getIt()),
    );
  }
}
