import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fithub_portal_admin/config/theme/app_colors.dart';
import 'package:fithub_portal_admin/core/network/supabase_locale_headers.dart';

void main() {
  test('Stitch Kinetic Monolith tokens match get_project namedColors', () {
    expect(AppColors.background.toARGB32(), 0xFF131313);
    expect(AppColors.primaryContainer.toARGB32(), 0xFFC3F400);
    expect(AppColors.primaryFixedDim.toARGB32(), 0xFFABD600);
    expect(AppColors.errorContainer.toARGB32(), 0xFF93000A);
    expect(AppColors.error.toARGB32(), 0xFFFFB4AB);
    expect(AppColors.electricLime.toARGB32(), 0xFFCCFF00);
  });

  test('translation assets expose auth.login.cta_initialize_session', () async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final enRaw =
        await rootBundle.loadString('assets/translations/en.json');
    final arRaw =
        await rootBundle.loadString('assets/translations/ar.json');
    final en = jsonDecode(enRaw) as Map<String, dynamic>;
    final ar = jsonDecode(arRaw) as Map<String, dynamic>;

    expect(
      en['auth']['login']['cta_initialize_session'],
      'INITIALIZE SESSION',
    );
    expect(
      ar['auth']['login']['cta_initialize_session'],
      'بدء الجلسة',
    );
    expect(
      en['connectivity']['safe_mode']['banner'],
      isA<String>(),
    );
  });

  test('Accept-Language initialHeaders normalize to en|ar', () {
    expect(
      SupabaseLocaleHeaders.initialHeaders('en')['Accept-Language'],
      'en',
    );
    expect(
      SupabaseLocaleHeaders.initialHeaders('ar')['Accept-Language'],
      'ar',
    );
    expect(
      SupabaseLocaleHeaders.initialHeaders('ar_SA')['Accept-Language'],
      'ar',
    );
    expect(
      SupabaseLocaleHeaders.initialHeaders('fr')['Accept-Language'],
      'en',
    );
  });
}
