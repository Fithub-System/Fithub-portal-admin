import 'package:get_it/get_it.dart';

import 'package:fithub_portal_admin/core/network/cloud_mutation_guard.dart';
import 'package:fithub_portal_admin/features/admin_payout_queue/data/data_sources/remote/admin_payout_queue_remote_data_source.dart';
import 'package:fithub_portal_admin/features/admin_payout_queue/data/repositories/admin_payout_queue_repository_impl.dart';
import 'package:fithub_portal_admin/features/admin_payout_queue/domain/repositories/admin_payout_queue_repository.dart';
import 'package:fithub_portal_admin/features/admin_payout_queue/domain/use_cases/admin_payout_queue_use_cases.dart';
import 'package:fithub_portal_admin/features/admin_payout_queue/presentation/bloc/admin_payout_queue_bloc.dart';

/// Admin payout queue feature DI (FEAT-30) — `cleanarch admin_payout_queue -b`.
void registerAdminPayoutQueueDependencies(GetIt getIt) {
  if (!getIt.isRegistered<AdminPayoutQueueRemoteDataSource>()) {
    getIt.registerLazySingleton<AdminPayoutQueueRemoteDataSource>(
      AdminPayoutQueueSupabaseRemoteDataSource.new,
    );
  }

  if (!getIt.isRegistered<AdminPayoutQueueRepository>()) {
    getIt.registerLazySingleton<AdminPayoutQueueRepository>(
      () => AdminPayoutQueueRepositoryImpl(remote: getIt()),
    );
  }

  if (!getIt.isRegistered<ListAdminPayoutRequestsUseCase>()) {
    getIt.registerLazySingleton(
      () => ListAdminPayoutRequestsUseCase(getIt()),
    );
  }

  if (!getIt.isRegistered<FulfillAdminPayoutUseCase>()) {
    getIt.registerLazySingleton(
      () => FulfillAdminPayoutUseCase(
        getIt(),
        cloudGuard: getIt<CloudMutationGuard>(),
      ),
    );
  }

  if (!getIt.isRegistered<AdminPayoutQueueBloc>()) {
    getIt.registerFactory(
      () => AdminPayoutQueueBloc(
        listRequests: getIt(),
        fulfill: getIt(),
      ),
    );
  }
}
