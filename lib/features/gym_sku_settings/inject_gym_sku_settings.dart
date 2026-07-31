import 'package:get_it/get_it.dart';

import 'package:fithub_portal_admin/features/auth/domain/repositories/auth_repository.dart';
import 'package:fithub_portal_admin/features/gym_sku_settings/data/data_sources/remote/gym_sku_settings_remote_data_source.dart';
import 'package:fithub_portal_admin/features/gym_sku_settings/data/repositories/gym_sku_settings_repository_impl.dart';
import 'package:fithub_portal_admin/features/gym_sku_settings/domain/repositories/gym_sku_settings_repository.dart';
import 'package:fithub_portal_admin/features/gym_sku_settings/domain/use_cases/gym_sku_settings_use_case.dart';
import 'package:fithub_portal_admin/features/gym_sku_settings/presentation/bloc/gym_sku_settings_bloc.dart';

/// Gym SKU settings feature DI (FEAT-10 Install I3).
///
/// Scaffolded via `cleanarch gym_sku_settings -b`.
void registerGymSkuSettingsDependencies(GetIt getIt) {
  if (!getIt.isRegistered<GymSkuSettingsRemoteDataSource>()) {
    getIt.registerLazySingleton<GymSkuSettingsRemoteDataSource>(
      GymSkuSettingsSupabaseRemoteDataSource.new,
    );
  }

  if (!getIt.isRegistered<GymSkuSettingsRepository>()) {
    getIt.registerLazySingleton<GymSkuSettingsRepository>(
      () => GymSkuSettingsRepositoryImpl(
        remote: getIt(),
        resolveTenantId: () async {
          final auth = getIt<AuthRepository>();
          final cached = await auth.readCachedProfile();
          if (cached != null) return cached.tenantId;
          final profile = await auth.resolveEmployeeProfile();
          return profile.tenantId;
        },
      ),
    );
  }

  if (!getIt.isRegistered<GetGymSkuSettingsUseCase>()) {
    getIt.registerLazySingleton(() => GetGymSkuSettingsUseCase(getIt()));
  }
  if (!getIt.isRegistered<SetGymSkuSettingsUseCase>()) {
    getIt.registerLazySingleton(() => SetGymSkuSettingsUseCase(getIt()));
  }

  if (!getIt.isRegistered<GymSkuSettingsBloc>()) {
    getIt.registerFactory(
      () => GymSkuSettingsBloc(
        getSettings: getIt(),
        setSettings: getIt(),
      ),
    );
  }
}
