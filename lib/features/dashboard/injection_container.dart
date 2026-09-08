import 'package:get_it/get_it.dart';

import '../../core/network/api_provider.dart';
import '../../core/network/occupancy_backend.dart';
import '../../core/database/app_database.dart';
import '../access_scanner/domain/repositories/member_roster_repository.dart';
import '../access_scanner/domain/use_cases/sync_member_roster_use_case.dart';
import 'data/datasources/gyms_occupancy_drift_local_data_source.dart';
import 'data/datasources/gyms_occupancy_http_remote_data_source.dart';
import 'data/datasources/gyms_occupancy_local_data_source.dart';
import 'data/datasources/gyms_occupancy_remote_data_source.dart';
import 'data/datasources/gyms_occupancy_supabase_remote_data_source.dart';
import 'data/datasources/overview_metrics_remote_data_source.dart';
import 'data/datasources/overview_metrics_supabase_remote_data_source.dart';
import 'data/repositories/gyms_occupancy_repository_impl.dart';
import 'data/repositories/overview_home_metrics_repository_impl.dart';
import 'domain/repositories/gyms_occupancy_repository.dart';
import 'presentation/cubit/overview_metrics_cubit.dart';

/// Dashboard feature DI (FEAT-04 AC-C5 + FEAT-60 metrics).
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

  if (!getIt.isRegistered<OverviewMetricsRemoteDataSource>()) {
    getIt.registerLazySingleton<OverviewMetricsRemoteDataSource>(
      OverviewMetricsSupabaseRemoteDataSource.new,
    );
  }
}

/// Factory for FEAT-60 Overview metrics Cubit (tenant-scoped).
OverviewMetricsCubit createOverviewMetricsCubit({
  required GetIt getIt,
  required String tenantId,
  bool Function()? isOnline,
}) {
  final sync = getIt.isRegistered<SyncMemberRosterUseCase>()
      ? getIt<SyncMemberRosterUseCase>()
      : null;
  final repository = OverviewHomeMetricsRepositoryImpl(
    memberRosterRepository: getIt<MemberRosterRepository>(),
    remote: getIt<OverviewMetricsRemoteDataSource>(),
    syncRoster: sync,
    isOnline: isOnline,
  );
  return OverviewMetricsCubit(repository: repository, tenantId: tenantId);
}
