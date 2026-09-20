import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fithub_portal_admin/config/theme/app_colors.dart';
import 'package:fithub_portal_admin/features/auth/domain/entities/employee_profile.dart';
import 'package:fithub_portal_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fithub_portal_admin/features/auth/presentation/pages/login_page.dart';
import 'package:fithub_portal_admin/features/access_scanner/injection_container.dart'
    as access_scanner_di;
import 'package:fithub_portal_admin/features/connectivity/presentation/cubit/connectivity_cubit.dart';
import 'package:fithub_portal_admin/features/dashboard/injection_container.dart'
    as dashboard_di;
import 'package:fithub_portal_admin/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:fithub_portal_admin/features/gym_onboarding/presentation/screens/gym_onboarding_wizard_page.dart';
import 'package:fithub_portal_admin/features/gym_onboarding/presentation/screens/gym_register_page.dart';
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
      buildWhen: (previous, current) {
        if (_isLoginSurface(previous) && _isLoginSurface(current)) {
          return false;
        }
        if (previous.runtimeType != current.runtimeType) return true;
        if (previous is AuthAuthenticated && current is AuthAuthenticated) {
          return previous.showOnboardingWizard !=
                  current.showOnboardingWizard ||
              previous.profile != current.profile;
        }
        return false;
      },
      builder: (context, state) {
        return switch (state) {
          AuthAuthenticated() when state.showOnboardingWizard => BlocProvider(
            create: (_) =>
                InjectionContainer.createGymOnboardingCubit()..load(),
            child: const GymOnboardingWizardPage(),
          ),
          AuthAuthenticated(:final profile) => _AuthenticatedShell(
            profile: profile,
          ),
          AuthAwaitingEmailConfirmation(:final email) => GymCheckEmailPage(
            email: email,
          ),
          AuthInitial() || AuthLoading() => const _SplashScaffold(),
          _ => const LoginPage(),
        };
      },
    );
  }

  /// Login stays mounted while the founder form is open so register is not
  /// a cold-start route — it only appears after the Register CTA.
  static bool _isLoginSurface(AuthState state) =>
      state is AuthUnauthenticated || state is AuthRegisterForm;
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
        BlocProvider(
          create: (_) => dashboard_di.createOverviewMetricsCubit(
            getIt: InjectionContainer.locator,
            tenantId: profile.tenantId,
            isOnline: () => connectivity.isOnline,
          )..start(),
        ),
        BlocProvider(
          create: (context) {
            final scannerCubit = access_scanner_di.createAccessScannerCubit(
              getIt: getIt,
              tenantId: profile.tenantId,
              isOnline: () => connectivity.isOnline,
              onScanProcessed: (result) {
                context.read<DashboardCubit>().reportScanResult(result);
              },
            )..start();
            return scannerCubit;
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
