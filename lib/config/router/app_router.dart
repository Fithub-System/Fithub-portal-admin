import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fithub_portal_admin/config/theme/app_colors.dart';
import 'package:fithub_portal_admin/features/auth/domain/entities/employee_profile.dart';
import 'package:fithub_portal_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fithub_portal_admin/features/auth/presentation/pages/login_page.dart';
import 'package:fithub_portal_admin/features/connectivity/presentation/cubit/connectivity_cubit.dart';
import 'package:fithub_portal_admin/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:fithub_portal_admin/features/home/presentation/pages/portal_home_shell.dart';
import 'package:fithub_portal_admin/features/offline_sync/presentation/cubit/offline_sync_cubit.dart';
import 'package:fithub_portal_admin/injection_container.dart';

/// Auth gate: login vs Portal home shell (AC-A1 / AC-D1).
class AppRouter {
  const AppRouter._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Widget authGate() {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType,
      builder: (context, state) {
        return switch (state) {
          AuthAuthenticated(:final profile) => _AuthenticatedShell(
            profile: profile,
          ),
          AuthInitial() || AuthLoading() => const _SplashScaffold(),
          _ => const LoginPage(),
        };
      },
    );
  }
}

class _AuthenticatedShell extends StatelessWidget {
  const _AuthenticatedShell({required this.profile});

  final EmployeeProfile profile;

  @override
  Widget build(BuildContext context) {
    final connectivity = InjectionContainer.connectivityService;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ConnectivityCubit(connectivity)..start()),
        BlocProvider(
          create: (_) {
            final cubit = OfflineSyncCubit(
              syncPendingAttendance: InjectionContainer.syncPendingAttendance,
              tenantId: profile.tenantId,
              isOnline: () => connectivity.isOnline,
              onConnectivityChanged: connectivity.onStatusChanged,
            );
            cubit.start();
            return cubit;
          },
        ),
        BlocProvider(
          create: (context) {
            final cubit = DashboardCubit(
              local: InjectionContainer.gymsOccupancyLocalDataSource,
              gymsRepository: InjectionContainer.gymsOccupancyRepository,
              tenantId: profile.tenantId,
              isOnline: () => connectivity.isOnline,
              onConnectivityChanged: connectivity.onStatusChanged,
              scanRepository: InjectionContainer.scanRepository,
            );
            cubit.start();
            return cubit;
          },
        ),
      ],
      child: const PortalHomeShell(),
    );
  }
}

class _SplashScaffold extends StatelessWidget {
  const _SplashScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primaryContainer),
      ),
    );
  }
}
