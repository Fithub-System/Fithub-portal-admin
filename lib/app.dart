import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'config/theme/dark_theme.dart';
import 'config/theme/theme_manager.dart';
import 'config/auth/auth_manager.dart';
import 'config/router/app_router.dart';
import 'config/app_helper/app_constants.dart';
import 'core/database/app_database.dart';
import 'core/network/connectivity_service.dart';
import 'features/connectivity/presentation/cubit/connectivity_cubit.dart';
import 'features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/scan/data/repositories/scan_repository.dart';
import 'injection_container.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    themeManager.addListener(_notifyChange);
    authManager.addListener(_notifyChange);
  }

  @override
  void dispose() {
    themeManager.removeListener(_notifyChange);
    authManager.removeListener(_notifyChange);
    super.dispose();
  }

  void _notifyChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final database = getIt<AppDatabase>();
    final connectivity = getIt<ConnectivityService>();
    final tenantId = getIt<String>(instanceName: 'tenantId');

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ConnectivityCubit(connectivity)..start(),
        ),
        BlocProvider(
          create: (_) => DashboardCubit(
            database: database,
            scanRepository: getIt<ScanRepository>(),
            tenantId: tenantId,
          )..load(),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: kineticDarkTheme,
        debugShowCheckedModeBanner: false,
        navigatorKey: AppRouter.navigatorKey,
        initialRoute: '/',
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
