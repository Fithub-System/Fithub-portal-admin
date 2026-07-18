import 'package:flutter/material.dart';
import 'package:fithub_portal_admin/app.dart';
import 'package:fithub_portal_admin/core/network/supabase_config.dart';
import 'package:fithub_portal_admin/injection_container.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.anonKey,
    );
  }

  await InjectionContainer.init();
  runApp(const App());
}
