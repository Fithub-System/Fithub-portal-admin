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
import 'package:fithub_portal_admin/features/memberships/inject_memberships.dart'
    as memberships_di;
import 'package:fithub_portal_admin/features/billing/inject_billing.dart'
    as billing_di;
import 'package:fithub_portal_admin/features/marketing/inject_marketing.dart'
    as marketing_di;
import 'package:fithub_portal_admin/features/members/inject_members.dart'
    as members_di;
import 'package:fithub_portal_admin/features/add_member/inject_add_member.dart'
    as add_member_di;
import 'package:fithub_portal_admin/features/gym_sku_settings/inject_gym_sku_settings.dart'
    as gym_sku_settings_di;
import 'package:fithub_portal_admin/features/class_sessions/inject_class_sessions.dart'
    as class_sessions_di;
import 'package:fithub_portal_admin/features/staff_invite/presentation/bloc/staff_invite_bloc.dart';
import 'package:fithub_portal_admin/features/memberships/presentation/cubit/memberships_cubit.dart';
import 'package:fithub_portal_admin/features/billing/presentation/cubit/billing_cubit.dart';
import 'package:fithub_portal_admin/features/marketing/presentation/bloc/marketing_bloc.dart';
import 'package:fithub_portal_admin/features/add_member/presentation/bloc/add_member_bloc.dart';
import 'package:fithub_portal_admin/features/gym_sku_settings/presentation/bloc/gym_sku_settings_bloc.dart';
import 'package:fithub_portal_admin/features/class_sessions/presentation/cubit/class_sessions_cubit.dart';
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
    memberships_di.registerMembershipsDependencies(getIt);
    billing_di.registerBillingDependencies(getIt);
    marketing_di.registerMarketingDependencies(getIt);
    members_di.registerMembersDependencies(getIt);
    add_member_di.registerAddMemberDependencies(getIt);
    gym_sku_settings_di.registerGymSkuSettingsDependencies(getIt);
    class_sessions_di.registerClassSessionsDependencies(getIt);

    if (!getIt.isRegistered<ScanRepository>()) {
      getIt.registerLazySingleton<ScanRepository>(
        () => ScanRepository(database: getIt()),
      );
    }
  }

  static StaffInviteBloc createStaffInviteBloc() => getIt<StaffInviteBloc>();

  static MembershipsCubit createMembershipsCubit() => getIt<MembershipsCubit>();

  static AddMemberBloc createAddMemberBloc() => getIt<AddMemberBloc>();

  static BillingCubit createBillingCubit() => getIt<BillingCubit>();

  static MarketingBloc createMarketingBloc() => getIt<MarketingBloc>();

  static GymSkuSettingsBloc createGymSkuSettingsBloc() =>
      getIt<GymSkuSettingsBloc>();

  static ClassSessionsCubit createClassSessionsCubit() =>
      getIt<ClassSessionsCubit>();

  static GetIt get locator => getIt;

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
