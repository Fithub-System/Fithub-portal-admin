import 'package:flutter/material.dart';

import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import 'unknown_route.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const DashboardPage(),
          settings: settings,
        );
      default:
        return unknownRoute;
    }
  }

  static BuildContext get currentContext => navigatorKey.currentState!.context;

  static Route get unknownRoute =>
      MaterialPageRoute(builder: (context) => const UnknownRoute());

  static void pop(dynamic data) {
    navigatorKey.currentState?.pop(data);
  }

  static Future<Object?>? to(String route, {Object? data}) async {
    return navigatorKey.currentState?.pushNamed(route, arguments: data);
  }

  static Future<Object?>? toReplacement(String route, {Object? data}) async {
    return navigatorKey.currentState
        ?.pushReplacementNamed(route, arguments: data);
  }

  static Future<Object?>? toAndRemoveUntil(String route, {Object? data}) async {
    return navigatorKey.currentState
        ?.pushNamedAndRemoveUntil(route, (route) => false, arguments: data);
  }
}
