import 'package:get_it/get_it.dart';

import 'package:fithub_portal_admin/core/network/api_provider.dart';
import 'package:fithub_portal_admin/core/network/cloud_mutation_guard.dart';
import 'package:fithub_portal_admin/features/add_member/data/data_sources/remote/add_member_remote_data_source.dart';
import 'package:fithub_portal_admin/features/add_member/data/data_sources/remote/member_invite_remote_data_source.dart';
import 'package:fithub_portal_admin/features/add_member/data/repositories/add_member_repository_impl.dart';
import 'package:fithub_portal_admin/features/add_member/domain/repositories/add_member_repository.dart';
import 'package:fithub_portal_admin/features/add_member/domain/use_cases/add_member_use_cases.dart';
import 'package:fithub_portal_admin/features/add_member/presentation/bloc/add_member_bloc.dart';
import 'package:fithub_portal_admin/features/memberships/domain/use_cases/memberships_use_cases.dart';

/// Add Member feature DI (FEAT-13 Link + FEAT-62 Invite) — cleanarch `add_member -b`.
void registerAddMemberDependencies(GetIt getIt) {
  if (!getIt.isRegistered<AddMemberRemoteDataSource>()) {
    getIt.registerLazySingleton<AddMemberRemoteDataSource>(
      AddMemberSupabaseRemoteDataSource.new,
    );
  }

  if (!getIt.isRegistered<MemberInviteRemoteDataSource>()) {
    getIt.registerLazySingleton<MemberInviteRemoteDataSource>(
      () => MemberInviteHttpRemoteDataSource(getIt<ApiProvider>()),
    );
  }

  if (!getIt.isRegistered<AddMemberRepository>()) {
    getIt.registerLazySingleton<AddMemberRepository>(
      () => AddMemberRepositoryImpl(remote: getIt(), inviteRemote: getIt()),
    );
  }

  if (!getIt.isRegistered<FindAthleteForEnrollUseCase>()) {
    getIt.registerLazySingleton(() => FindAthleteForEnrollUseCase(getIt()));
  }
  if (!getIt.isRegistered<EnrollGymMemberUseCase>()) {
    getIt.registerLazySingleton(() => EnrollGymMemberUseCase(getIt()));
  }
  if (!getIt.isRegistered<InviteMemberUseCase>()) {
    getIt.registerLazySingleton(
      () =>
          InviteMemberUseCase(getIt(), cloudGuard: getIt<CloudMutationGuard>()),
    );
  }

  if (!getIt.isRegistered<AddMemberBloc>()) {
    getIt.registerFactory(
      () => AddMemberBloc(
        findAthlete: getIt(),
        enrollGymMember: getIt(),
        inviteMember: getIt(),
        listPlans: getIt<ListMembershipPlansUseCase>(),
        assignMembership: getIt<AssignMembershipUseCase>(),
      ),
    );
  }
}

AddMemberBloc createAddMemberBloc(GetIt getIt) => getIt<AddMemberBloc>();
