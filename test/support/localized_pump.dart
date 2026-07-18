import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fithub_portal_admin/core/i18n/app_locales.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic>? _en;
Map<String, dynamic>? _ar;

Future<void> ensureTestTranslationsLoaded() async {
  if (_en != null && _ar != null) return;
  TestWidgetsFlutterBinding.ensureInitialized();
  _en = json.decode(
    await rootBundle.loadString('assets/translations/en.json'),
  ) as Map<String, dynamic>;
  _ar = json.decode(
    await rootBundle.loadString('assets/translations/ar.json'),
  ) as Map<String, dynamic>;
}

class _PreloadedAssetLoader extends AssetLoader {
  const _PreloadedAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    await ensureTestTranslationsLoaded();
    if (locale.languageCode == 'ar') return Map<String, dynamic>.from(_ar!);
    return Map<String, dynamic>.from(_en!);
  }
}

/// Boots EasyLocalization for widget tests with preloaded JSON (no I/O races).
Future<void> pumpLocalizedApp(
  WidgetTester tester,
  Widget home, {
  Locale locale = AppLocales.en,
  ThemeData? theme,
  Finder? waitFor,
}) async {
  SharedPreferences.setMockInitialValues({});
  await ensureTestTranslationsLoaded();
  await EasyLocalization.ensureInitialized();

  await tester.binding.setSurfaceSize(const Size(1200, 1600));
  addTearDown(() async {
    await tester.binding.setSurfaceSize(null);
  });

  await tester.pumpWidget(
    EasyLocalization(
      key: UniqueKey(),
      supportedLocales: AppLocales.supported,
      path: AppLocales.translationsPath,
      fallbackLocale: AppLocales.fallback,
      startLocale: locale,
      saveLocale: false,
      assetLoader: const _PreloadedAssetLoader(),
      child: Builder(
        builder: (context) {
          return MaterialApp(
            theme: theme ?? ThemeData.dark(useMaterial3: true),
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            home: home,
          );
        },
      ),
    ),
  );

  final target = waitFor;
  for (var i = 0; i < 40; i++) {
    await tester.pump();
    if (target != null && target.evaluate().isNotEmpty) {
      return;
    }
    await tester.pump(const Duration(milliseconds: 16));
  }
}
