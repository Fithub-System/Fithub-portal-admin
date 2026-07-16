// lib/main.dart
import 'package:flutter/material.dart';

import 'app.dart';
import 'injection_container.dart';

import 'config/theme/theme_manager.dart';
import 'config/auth/auth_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  themeManager = await ThemeManager.loadTheme();
  
  // Initialize user manager (generic - can work with any user model)
  authManager = await AuthManager.loadUser();
  
  Future.wait([
    ServiceLocator().setup(),
  ]).then((value) {
    runApp(App());
  });
}
