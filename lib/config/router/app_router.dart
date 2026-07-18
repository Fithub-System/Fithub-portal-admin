import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fithub_portal_admin/config/theme/app_colors.dart';
import 'package:fithub_portal_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fithub_portal_admin/features/auth/presentation/pages/login_page.dart';
import 'package:fithub_portal_admin/features/home/presentation/pages/portal_home_shell.dart';

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
          AuthAuthenticated() => const PortalHomeShell(),
          AuthInitial() || AuthLoading() => const _SplashScaffold(),
          _ => const LoginPage(),
        };
      },
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
