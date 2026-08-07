import 'package:get_it/get_it.dart';

import 'package:fithub_portal_admin/core/network/cloud_mutation_guard.dart';
import 'package:fithub_portal_admin/features/marketing/data/data_sources/remote/marketing_remote_data_source.dart';
import 'package:fithub_portal_admin/features/marketing/data/repositories/marketing_repository_impl.dart';
import 'package:fithub_portal_admin/features/marketing/domain/repositories/marketing_repository.dart';
import 'package:fithub_portal_admin/features/marketing/domain/use_cases/marketing_use_cases.dart';
import 'package:fithub_portal_admin/features/marketing/presentation/bloc/marketing_bloc.dart';

/// Marketing feature DI (FEAT-23) — `cleanarch marketing -b`.
void registerMarketingDependencies(GetIt getIt) {
  if (!getIt.isRegistered<MarketingRemoteDataSource>()) {
    getIt.registerLazySingleton<MarketingRemoteDataSource>(
      MarketingSupabaseRemoteDataSource.new,
    );
  }

  if (!getIt.isRegistered<MarketingRepository>()) {
    getIt.registerLazySingleton<MarketingRepository>(
      () => MarketingRepositoryImpl(remote: getIt()),
    );
  }

  if (!getIt.isRegistered<ListMarketingCampaignsUseCase>()) {
    getIt.registerLazySingleton(() => ListMarketingCampaignsUseCase(getIt()));
  }
  if (!getIt.isRegistered<ListPromoCodesUseCase>()) {
    getIt.registerLazySingleton(() => ListPromoCodesUseCase(getIt()));
  }
  if (!getIt.isRegistered<UpsertMarketingCampaignUseCase>()) {
    getIt.registerLazySingleton(
      () => UpsertMarketingCampaignUseCase(
        getIt(),
        cloudGuard: getIt<CloudMutationGuard>(),
      ),
    );
  }
  if (!getIt.isRegistered<UpsertPromoCodeUseCase>()) {
    getIt.registerLazySingleton(
      () => UpsertPromoCodeUseCase(
        getIt(),
        cloudGuard: getIt<CloudMutationGuard>(),
      ),
    );
  }

  if (!getIt.isRegistered<MarketingBloc>()) {
    getIt.registerFactory(
      () => MarketingBloc(
        listCampaigns: getIt(),
        listPromoCodes: getIt(),
        upsertCampaign: getIt(),
        upsertPromoCode: getIt(),
      ),
    );
  }
}
