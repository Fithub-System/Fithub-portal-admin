import 'package:get_it/get_it.dart';

import 'package:fithub_portal_admin/core/database/app_database.dart';
import 'package:fithub_portal_admin/features/offline_sync/domain/use_cases/offline_sync_use_case.dart';
import 'package:fithub_portal_admin/features/scan/data/repositories/scan_repository.dart';
import 'data/data_sources/local/member_roster_local_data_source.dart';
import 'data/data_sources/remote/member_roster_remote_data_source.dart';
import 'data/data_sources/remote/member_roster_supabase_remote_data_source.dart';
import 'data/repositories/member_roster_repository_impl.dart';
import 'domain/repositories/member_roster_repository.dart';
import 'domain/use_cases/process_qr_scan_use_case.dart';
import 'domain/use_cases/sync_member_roster_use_case.dart';
import 'presentation/cubit/access_scanner_cubit.dart';

/// Access scanner feature DI (FEAT-01 / `cleanarch access_scanner -c`).
void registerAccessScannerDependencies(GetIt getIt) {
  if (!getIt.isRegistered<MemberRosterLocalDataSource>()) {
    getIt.registerLazySingleton<MemberRosterLocalDataSource>(
      () => MemberRosterDriftLocalDataSource(getIt<AppDatabase>()),
    );
  }

  if (!getIt.isRegistered<MemberRosterRemoteDataSource>()) {
    getIt.registerLazySingleton<MemberRosterRemoteDataSource>(
      MemberRosterSupabaseRemoteDataSource.new,
    );
  }

  if (!getIt.isRegistered<MemberRosterRepository>()) {
    getIt.registerLazySingleton<MemberRosterRepository>(
      () => MemberRosterRepositoryImpl(remote: getIt(), local: getIt()),
    );
  }

  if (!getIt.isRegistered<ProcessQrScanUseCase>()) {
    getIt.registerLazySingleton(
      () => ProcessQrScanUseCase(
        getIt<ScanRepository>(),
        syncPendingAttendance: getIt.isRegistered<SyncPendingAttendanceUseCase>()
            ? getIt<SyncPendingAttendanceUseCase>()
            : null,
      ),
    );
  }

  if (!getIt.isRegistered<SyncMemberRosterUseCase>()) {
    getIt.registerLazySingleton(
      () => SyncMemberRosterUseCase(getIt<MemberRosterRepository>()),
    );
  }
}

/// Factory for shell-scoped cubit (tenant + connectivity injected at call site).
AccessScannerCubit createAccessScannerCubit({
  required GetIt getIt,
  required String tenantId,
  required bool Function() isOnline,
  void Function(ScanProcessResult result)? onScanProcessed,
}) {
  return AccessScannerCubit(
    processQrScan: getIt<ProcessQrScanUseCase>(),
    syncMemberRoster: getIt<SyncMemberRosterUseCase>(),
    memberRosterRepository: getIt<MemberRosterRepository>(),
    tenantId: tenantId,
    isOnline: isOnline,
    onScanProcessed: onScanProcessed,
  );
}
