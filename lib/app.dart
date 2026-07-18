import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fithub_portal_admin/config/router/app_router.dart';
import 'package:fithub_portal_admin/config/theme/app_theme.dart';
import 'package:fithub_portal_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fithub_portal_admin/injection_container.dart';

/// Root widget for Pulse Gym Admin Portal (fithub_portal_admin).
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(authRepository: InjectionContainer.authRepository)
        ..add(const AuthStarted()),
      child: MaterialApp(
        title: 'Gym Connect Portal',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        navigatorKey: AppRouter.navigatorKey,
        home: AppRouter.authGate(),
      ),
    );
  }
}
