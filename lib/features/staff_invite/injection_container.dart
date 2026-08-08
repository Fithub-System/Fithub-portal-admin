import 'package:get_it/get_it.dart';

import 'package:fithub_portal_admin/core/network/api_provider.dart';
import 'package:fithub_portal_admin/core/network/cloud_mutation_guard.dart';
import 'package:fithub_portal_admin/features/staff_invite/data/data_sources/remote/staff_invite_http_remote_data_source.dart';
import 'package:fithub_portal_admin/features/staff_invite/data/data_sources/remote/staff_invite_remote_data_source.dart';
import 'package:fithub_portal_admin/features/staff_invite/data/repositories/staff_invite_repository_impl.dart';
import 'package:fithub_portal_admin/features/staff_invite/domain/repositories/staff_invite_repository.dart';
import 'package:fithub_portal_admin/features/staff_invite/domain/use_cases/staff_invite_use_case.dart';
import 'package:fithub_portal_admin/features/staff_invite/presentation/bloc/staff_invite_bloc.dart';

/// Staff invite feature DI (FEAT-05 / kit per-feature container).
void registerStaffInviteDependencies(GetIt getIt) {
  if (!getIt.isRegistered<StaffInviteRemoteDataSource>()) {
    getIt.registerLazySingleton<StaffInviteRemoteDataSource>(
      () => StaffInviteHttpRemoteDataSource(getIt<ApiProvider>()),
    );
  }

  if (!getIt.isRegistered<StaffInviteRepository>()) {
    getIt.registerLazySingleton<StaffInviteRepository>(
      () => StaffInviteRepositoryImpl(remote: getIt()),
    );
  }

  if (!getIt.isRegistered<InviteStaffUseCase>()) {
    getIt.registerLazySingleton(
      () => InviteStaffUseCase(
        getIt(),
        cloudGuard: getIt<CloudMutationGuard>(),
      ),
    );
  }

  if (!getIt.isRegistered<StaffInviteBloc>()) {
    getIt.registerFactory(() => StaffInviteBloc(inviteStaffUseCase: getIt()));
  }
}
