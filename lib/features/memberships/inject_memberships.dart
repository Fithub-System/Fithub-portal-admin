import 'package:get_it/get_it.dart';

import 'package:fithub_portal_admin/features/auth/domain/repositories/auth_repository.dart';
import 'package:fithub_portal_admin/features/memberships/data/data_sources/remote/memberships_remote_data_source.dart';
import 'package:fithub_portal_admin/features/memberships/data/repositories/memberships_repository_impl.dart';
import 'package:fithub_portal_admin/features/memberships/domain/repositories/memberships_repository.dart';
import 'package:fithub_portal_admin/features/memberships/domain/use_cases/memberships_use_cases.dart';
import 'package:fithub_portal_admin/features/memberships/presentation/cubit/memberships_cubit.dart';

/// Memberships feature DI (FEAT-07).
void registerMembershipsDependencies(GetIt getIt) {
  if (!getIt.isRegistered<MembershipsRemoteDataSource>()) {
    getIt.registerLazySingleton<MembershipsRemoteDataSource>(
      MembershipsSupabaseRemoteDataSource.new,
    );
  }

  if (!getIt.isRegistered<MembershipsRepository>()) {
    getIt.registerLazySingleton<MembershipsRepository>(
      () => MembershipsRepositoryImpl(
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

  if (!getIt.isRegistered<ListMembershipPlansUseCase>()) {
    getIt.registerLazySingleton(() => ListMembershipPlansUseCase(getIt()));
  }
  if (!getIt.isRegistered<CreateMembershipPlanUseCase>()) {
    getIt.registerLazySingleton(() => CreateMembershipPlanUseCase(getIt()));
  }
  if (!getIt.isRegistered<DeactivateMembershipPlanUseCase>()) {
    getIt.registerLazySingleton(
      () => DeactivateMembershipPlanUseCase(getIt()),
    );
  }
  if (!getIt.isRegistered<AssignMembershipUseCase>()) {
    getIt.registerLazySingleton(() => AssignMembershipUseCase(getIt()));
  }
  if (!getIt.isRegistered<ListMembershipAthletesUseCase>()) {
    getIt.registerLazySingleton(() => ListMembershipAthletesUseCase(getIt()));
  }

  if (!getIt.isRegistered<MembershipsCubit>()) {
    getIt.registerFactory(
      () => MembershipsCubit(
        listPlans: getIt(),
        createPlan: getIt(),
        deactivatePlan: getIt(),
        assignMembership: getIt(),
        listAthletes: getIt(),
      ),
    );
  }
}
