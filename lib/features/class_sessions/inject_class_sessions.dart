import 'package:get_it/get_it.dart';

import 'package:fithub_portal_admin/features/class_sessions/data/data_sources/remote/class_sessions_remote_data_source.dart';
import 'package:fithub_portal_admin/features/class_sessions/data/repositories/class_sessions_repository_impl.dart';
import 'package:fithub_portal_admin/features/class_sessions/domain/repositories/class_sessions_repository.dart';
import 'package:fithub_portal_admin/features/class_sessions/domain/use_cases/class_sessions_use_cases.dart';
import 'package:fithub_portal_admin/features/class_sessions/presentation/cubit/class_sessions_cubit.dart';

/// Class sessions feature DI (FEAT-18).
void registerClassSessionsDependencies(GetIt getIt) {
  if (!getIt.isRegistered<ClassSessionsRemoteDataSource>()) {
    getIt.registerLazySingleton<ClassSessionsRemoteDataSource>(
      ClassSessionsSupabaseRemoteDataSource.new,
    );
  }

  if (!getIt.isRegistered<ClassSessionsRepository>()) {
    getIt.registerLazySingleton<ClassSessionsRepository>(
      () => ClassSessionsRepositoryImpl(remote: getIt()),
    );
  }

  if (!getIt.isRegistered<ListClassSessionsUseCase>()) {
    getIt.registerLazySingleton(() => ListClassSessionsUseCase(getIt()));
  }
  if (!getIt.isRegistered<ListClassCoachesUseCase>()) {
    getIt.registerLazySingleton(() => ListClassCoachesUseCase(getIt()));
  }
  if (!getIt.isRegistered<UpsertClassSessionUseCase>()) {
    getIt.registerLazySingleton(() => UpsertClassSessionUseCase(getIt()));
  }

  if (!getIt.isRegistered<ClassSessionsCubit>()) {
    getIt.registerFactory(
      () => ClassSessionsCubit(
        listSessions: getIt(),
        listCoaches: getIt(),
        upsertSession: getIt(),
      ),
    );
  }
}
