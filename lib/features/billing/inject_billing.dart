import 'package:get_it/get_it.dart';

import 'package:fithub_portal_admin/core/network/cloud_mutation_guard.dart';
import 'package:fithub_portal_admin/features/auth/domain/repositories/auth_repository.dart';
import 'package:fithub_portal_admin/features/billing/data/data_sources/remote/billing_remote_data_source.dart';
import 'package:fithub_portal_admin/features/billing/data/repositories/billing_repository_impl.dart';
import 'package:fithub_portal_admin/features/billing/domain/repositories/billing_repository.dart';
import 'package:fithub_portal_admin/features/billing/domain/use_cases/billing_use_cases.dart';
import 'package:fithub_portal_admin/features/billing/presentation/cubit/billing_cubit.dart';

/// Billing feature DI (FEAT-08).
void registerBillingDependencies(GetIt getIt) {
  if (!getIt.isRegistered<BillingRemoteDataSource>()) {
    getIt.registerLazySingleton<BillingRemoteDataSource>(
      BillingSupabaseRemoteDataSource.new,
    );
  }

  if (!getIt.isRegistered<BillingRepository>()) {
    getIt.registerLazySingleton<BillingRepository>(
      () => BillingRepositoryImpl(
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

  if (!getIt.isRegistered<ListMembershipChargesUseCase>()) {
    getIt.registerLazySingleton(() => ListMembershipChargesUseCase(getIt()));
  }
  if (!getIt.isRegistered<UpdateMembershipChargeStatusUseCase>()) {
    getIt.registerLazySingleton(
      () => UpdateMembershipChargeStatusUseCase(
        getIt(),
        cloudGuard: getIt<CloudMutationGuard>(),
      ),
    );
  }
  if (!getIt.isRegistered<ApplyBillingFreezeUseCase>()) {
    getIt.registerLazySingleton(
      () => ApplyBillingFreezeUseCase(
        getIt(),
        cloudGuard: getIt<CloudMutationGuard>(),
      ),
    );
  }

  if (!getIt.isRegistered<BillingCubit>()) {
    getIt.registerFactory(
      () => BillingCubit(
        listCharges: getIt(),
        updateStatus: getIt(),
        applyFreeze: getIt(),
      ),
    );
  }
}
