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
        resolveTenantId: () {
          throw StateError(
            'resolveTenantId must be overridden via createMembershipsCubit',
          );
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
}

/// Factory that binds tenant from cached/resolved employee profile.
MembershipsCubit createMembershipsCubit(GetIt getIt) {
  final auth = getIt<AuthRepository>();
  final remote = getIt<MembershipsRemoteDataSource>();
  final repository = MembershipsRepositoryImpl(
    remote: remote,
    resolveTenantId: () {
      throw const _DeferredTenantFailure();
    },
  );

  // Prefer reading tenant at call time via async resolve in use cases —
  // wrap createPlan through a tenant-aware repository proxy.
  final tenantAware = _TenantAwareMembershipsRepository(
    remote: remote,
    auth: auth,
  );

  return MembershipsCubit(
    listPlans: ListMembershipPlansUseCase(tenantAware),
    createPlan: CreateMembershipPlanUseCase(tenantAware),
    deactivatePlan: DeactivateMembershipPlanUseCase(tenantAware),
    assignMembership: AssignMembershipUseCase(tenantAware),
    listAthletes: ListMembershipAthletesUseCase(tenantAware),
  );
}

class _DeferredTenantFailure implements Exception {
  const _DeferredTenantFailure();
}

class _TenantAwareMembershipsRepository implements MembershipsRepository {
  _TenantAwareMembershipsRepository({
    required MembershipsRemoteDataSource remote,
    required AuthRepository auth,
  }) : _remote = remote,
       _auth = auth;

  final MembershipsRemoteDataSource _remote;
  final AuthRepository _auth;

  Future<String> _tenantId() async {
    final cached = await _auth.readCachedProfile();
    if (cached != null) return cached.tenantId;
    final profile = await _auth.resolveEmployeeProfile();
    return profile.tenantId;
  }

  @override
  Future<List> listPlans({bool activeOnly = false}) {
    return _remote.listPlans(activeOnly: activeOnly);
  }

  @override
  Future createPlan({
    required String name,
    String? description,
    required int durationDays,
    required int priceCents,
    String currency = 'EGP',
  }) async {
    final tenantId = await _tenantId();
    return _remote.createPlan(
      tenantId: tenantId,
      name: name,
      description: description,
      durationDays: durationDays,
      priceCents: priceCents,
      currency: currency,
    );
  }

  @override
  Future<void> deactivatePlan(String planId) {
    return _remote.deactivatePlan(planId);
  }

  @override
  Future<String> assignMembership({
    required String planId,
    required String athleteId,
  }) {
    return _remote.assignMembership(planId: planId, athleteId: athleteId);
  }

  @override
  Future<List> listEnrolledAthletes() {
    return _remote.listEnrolledAthletes();
  }
}
