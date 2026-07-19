import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fithub_portal_admin/app.dart';
import 'package:fithub_portal_admin/core/i18n/app_locales.dart';
import 'package:fithub_portal_admin/core/network/locale_code_holder.dart';
import 'package:fithub_portal_admin/core/network/supabase_config.dart';
import 'package:fithub_portal_admin/core/network/supabase_locale_headers.dart';
import 'package:fithub_portal_admin/injection_container.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  final startLocale = AppLocales.resolveStartLocale();
  LocaleCodeHolder.update(startLocale.languageCode);

  // AC-I6: Accept-Language on Supabase.initialize (see SupabaseLocaleHeaders).
  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.anonKey,
      headers: SupabaseLocaleHeaders.initialHeaders(startLocale.languageCode),
    );
  }

  await InjectionContainer.init();
  runApp(
    EasyLocalization(
      supportedLocales: AppLocales.supported,
      path: AppLocales.translationsPath,
      fallbackLocale: AppLocales.fallback,
      startLocale: startLocale,
      child: const App(),
    ),
  );
}
