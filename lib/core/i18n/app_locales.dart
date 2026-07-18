import 'package:flutter/material.dart';

/// FEAT-03 supported locales (en LTR / ar RTL).
abstract final class AppLocales {
  static const en = Locale('en');
  static const ar = Locale('ar');

  static const supported = <Locale>[en, ar];
  static const fallback = en;

  static const translationsPath = 'assets/translations';

  /// Device locale if en/ar; otherwise English fallback.
  static Locale resolveStartLocale() {
    final device = WidgetsBinding.instance.platformDispatcher.locale;
    if (device.languageCode == 'ar') return ar;
    if (device.languageCode == 'en') return en;
    return fallback;
  }
}
