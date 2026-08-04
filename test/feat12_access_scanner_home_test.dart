import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fithub_portal_admin/config/theme/kinetic_tokens.dart';
import 'package:fithub_portal_admin/core/i18n/app_locales.dart';
import 'package:fithub_portal_admin/features/access_scanner/presentation/screens/access_scanner_screen.dart';
import 'package:fithub_portal_admin/features/home/presentation/pages/portal_shell_destinations.dart';
import 'package:fithub_portal_admin/features/home/presentation/widgets/access_scanner_focus_host.dart';
import 'package:fithub_portal_admin/features/home/presentation/widgets/home_access_scanner_cta.dart';

import 'support/localized_pump.dart';

void main() {
  group('FEAT-12 Stitch G1 citations', () {
    test('KineticTokens cite locked EN + AR Check-in Gate ids', () {
      expect(
        KineticTokens.stitchAccessScannerScreenId,
        '3629845f7f1e402697f46cf5575e86da',
      );
      expect(
        KineticTokens.stitchAccessScannerScreenIdAr,
        'bec9356e2cb941798e66fa804ac78854',
      );
      expect(
        AccessScannerScreen.stitchScreenId,
        KineticTokens.stitchAccessScannerScreenId,
      );
      expect(
        AccessScannerScreen.stitchScreenIdAr,
        KineticTokens.stitchAccessScannerScreenIdAr,
      );
      expect(
        HomeAccessScannerCta.stitchScreenIdEn,
        '3629845f7f1e402697f46cf5575e86da',
      );
      expect(
        AccessScannerFocusHost.stitchScreenIdAr,
        'bec9356e2cb941798e66fa804ac78854',
      );
      expect(AccessScannerScreen.stitchScreenTitle, 'Check-in Gate');
    });

    test('Kinetic charcoal / lime unchanged', () {
      expect(KineticTokens.deepCharcoal, const Color(0xFF121212));
      expect(KineticTokens.electricLime, const Color(0xFFCCFF00));
    });
  });

  group('FEAT-12 shell IA', () {
    test('six rail destinations preserved; Scan not an index', () {
      expect(PortalShellDestinations.destinationCount, 6);
      expect(PortalShellDestinations.home, 0);
      expect(PortalShellDestinations.members, 1);
      expect(PortalShellDestinations.staff, 2);
      expect(PortalShellDestinations.classes, 3);
      expect(PortalShellDestinations.marketing, 4);
      expect(PortalShellDestinations.reports, 5);
    });
  });

  group('FEAT-12 Home Open scanner CTA', () {
    testWidgets('EN CTA panel renders and invokes open callback', (
      tester,
    ) async {
      var opened = false;
      await pumpLocalizedApp(
        tester,
        Scaffold(
          backgroundColor: KineticTokens.deepCharcoal,
          body: HomeAccessScannerCta(onOpenScanner: () => opened = true),
        ),
        waitFor: find.byKey(const Key('home-open-scanner-cta')),
      );

      expect(find.text('Check-in Gate'), findsOneWidget);
      expect(find.text('Open scanner'), findsOneWidget);
      expect(
        find.textContaining('3629845f7f1e402697f46cf5575e86da'),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('home-open-scanner-cta')));
      await tester.pump();
      expect(opened, isTrue);
    });

    testWidgets('AR CTA panel renders RTL copy + AR Stitch id', (tester) async {
      await pumpLocalizedApp(
        tester,
        Scaffold(
          backgroundColor: KineticTokens.deepCharcoal,
          body: HomeAccessScannerCta(onOpenScanner: () {}),
        ),
        locale: AppLocales.ar,
        waitFor: find.text('فتح الماسح'),
      );

      expect(find.text('بوابة تسجيل الدخول'), findsOneWidget);
      expect(find.text('فتح الماسح'), findsOneWidget);
      expect(
        find.textContaining('bec9356e2cb941798e66fa804ac78854'),
        findsOneWidget,
      );
    });
  });

  group('FEAT-12 Access Scanner focus host', () {
    test('Stitch G1 ids remain cited on focus host', () {
      expect(
        AccessScannerFocusHost.stitchScreenIdEn,
        '3629845f7f1e402697f46cf5575e86da',
      );
      expect(
        AccessScannerFocusHost.stitchScreenIdAr,
        'bec9356e2cb941798e66fa804ac78854',
      );
    });
  });
}
