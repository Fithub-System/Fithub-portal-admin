import 'package:get_it/get_it.dart';

import 'package:fithub_portal_admin/core/database/app_database.dart';
import 'package:fithub_portal_admin/features/offline_sync/data/data_sources/local/offline_sync_local_data_source.dart';
import 'package:fithub_portal_admin/features/offline_sync/data/data_sources/remote/offline_sync_remote_data_source.dart';
import 'package:fithub_portal_admin/features/offline_sync/data/data_sources/remote/offline_sync_supabase_remote_data_source.dart';
import 'package:fithub_portal_admin/features/offline_sync/data/repositories/offline_sync_repository_impl.dart';
import 'package:fithub_portal_admin/features/offline_sync/domain/repositories/offline_sync_repository.dart';
import 'package:fithub_portal_admin/features/offline_sync/domain/use_cases/offline_sync_use_case.dart';

/// Offline sync feature DI (Phase 1.3 / kit per-feature container).
void registerOfflineSyncDependencies(GetIt getIt) {
  if (!getIt.isRegistered<OfflineSyncLocalDataSource>()) {
    getIt.registerLazySingleton<OfflineSyncLocalDataSource>(
      () => OfflineSyncDriftLocalDataSource(getIt<AppDatabase>()),
    );
  }

  if (!getIt.isRegistered<OfflineSyncRemoteDataSource>()) {
    getIt.registerLazySingleton<OfflineSyncRemoteDataSource>(
      OfflineSyncSupabaseRemoteDataSource.new,
    );
  }

  if (!getIt.isRegistered<OfflineSyncRepository>()) {
    getIt.registerLazySingleton<OfflineSyncRepository>(
      () => OfflineSyncRepositoryImpl(local: getIt(), remote: getIt()),
    );
  }

  if (!getIt.isRegistered<SyncPendingAttendanceUseCase>()) {
    getIt.registerLazySingleton(() => SyncPendingAttendanceUseCase(getIt()));
  }
}
