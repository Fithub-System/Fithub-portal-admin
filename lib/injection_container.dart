import 'package:fithub_portal_admin/core/database/app_database.dart';
import 'package:fithub_portal_admin/core/network/api_provider.dart';
import 'package:fithub_portal_admin/core/network/connectivity_service.dart';
import 'package:fithub_portal_admin/core/network/injection_container.dart'
    as network_di;
import 'package:fithub_portal_admin/core/storage/secure_storage_service.dart';
import 'package:fithub_portal_admin/features/auth/domain/repositories/auth_repository.dart';
import 'package:fithub_portal_admin/features/auth/injection_container.dart'
    as auth_di;
import 'package:fithub_portal_admin/features/connectivity/injection_container.dart'
    as connectivity_di;
import 'package:fithub_portal_admin/features/dashboard/data/datasources/gyms_occupancy_local_data_source.dart';
import 'package:fithub_portal_admin/features/dashboard/domain/repositories/gyms_occupancy_repository.dart';
import 'package:fithub_portal_admin/features/dashboard/injection_container.dart'
    as dashboard_di;
import 'package:fithub_portal_admin/features/offline_sync/domain/use_cases/offline_sync_use_case.dart';
import 'package:fithub_portal_admin/features/offline_sync/injection_container.dart'
    as offline_sync_di;
import 'package:fithub_portal_admin/features/scan/data/repositories/scan_repository.dart';
import 'package:fithub_portal_admin/features/staff_invite/injection_container.dart'
    as staff_invite_di;
import 'package:fithub_portal_admin/features/access_scanner/injection_container.dart'
    as access_scanner_di;
import 'package:fithub_portal_admin/features/staff_invite/presentation/bloc/staff_invite_bloc.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

/// Root DI facade — orchestrates feature `register(GetIt)` helpers only.
class InjectionContainer {
  static Future<void> init() async {
    if (!getIt.isRegistered<AppDatabase>()) {
      getIt.registerLazySingleton<AppDatabase>(AppDatabase.new);
    }

    network_di.registerNetworkDependencies(getIt);
    auth_di.registerAuthDependencies(getIt);
    connectivity_di.registerConnectivityDependencies(getIt);
    dashboard_di.registerDashboardDependencies(getIt);
    offline_sync_di.registerOfflineSyncDependencies(getIt);
    staff_invite_di.registerStaffInviteDependencies(getIt);
    access_scanner_di.registerAccessScannerDependencies(getIt);

    if (!getIt.isRegistered<ScanRepository>()) {
      getIt.registerLazySingleton<ScanRepository>(
        () => ScanRepository(database: getIt()),
      );
    }
  }

  static StaffInviteBloc createStaffInviteBloc() => getIt<StaffInviteBloc>();

  static AuthRepository get authRepository => getIt<AuthRepository>();

  static AppDatabase get database => getIt<AppDatabase>();

  static ConnectivityService get connectivityService =>
      getIt<ConnectivityService>();

  static GymsOccupancyRepository get gymsOccupancyRepository =>
      getIt<GymsOccupancyRepository>();

  static GymsOccupancyLocalDataSource get gymsOccupancyLocalDataSource =>
      getIt<GymsOccupancyLocalDataSource>();

  static ApiProvider get apiProvider => getIt<ApiProvider>();

  static ScanRepository get scanRepository => getIt<ScanRepository>();

  static SyncPendingAttendanceUseCase get syncPendingAttendance =>
      getIt<SyncPendingAttendanceUseCase>();

  static SecureStorageService get secureStorage =>
      getIt<SecureStorageService>();
}

/// Backward-compatible alias used by legacy kit entrypoints.
class ServiceLocator {
  Future<void> setup() => InjectionContainer.init();
}
