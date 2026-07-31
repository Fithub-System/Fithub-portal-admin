import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fithub_portal_admin/config/theme/kinetic_tokens.dart';
import 'package:fithub_portal_admin/core/i18n/app_locales.dart';
import 'package:fithub_portal_admin/features/home/presentation/pages/portal_shell_destinations.dart';
import 'package:fithub_portal_admin/features/home/presentation/widgets/kinetic_coming_soon_empty.dart';
import 'package:fithub_portal_admin/features/staff_invite/presentation/screens/staff_invite_screen.dart';

import 'support/localized_pump.dart';

void main() {
  group('FEAT-11 shell destinations', () {
    test('exactly six destinations in Stitch order', () {
      expect(PortalShellDestinations.destinationCount, 6);
      expect(PortalShellDestinations.home, 0);
      expect(PortalShellDestinations.members, 1);
      expect(PortalShellDestinations.staff, 2);
      expect(PortalShellDestinations.classes, 3);
      expect(PortalShellDestinations.marketing, 4);
      expect(PortalShellDestinations.reports, 5);
      expect(PortalShellDestinations.dashboard, PortalShellDestinations.home);
    });

    test('Scan and Account are not rail destination indices', () {
      // AC-A2: no nav.scan / nav.account as rail destinations.
      // Indices 0..5 are only Home..Reports — no scan/account slots.
      final indices = {
        PortalShellDestinations.home,
        PortalShellDestinations.members,
        PortalShellDestinations.staff,
        PortalShellDestinations.classes,
        PortalShellDestinations.marketing,
        PortalShellDestinations.reports,
      };
      expect(indices.length, 6);
      expect(indices, {0, 1, 2, 3, 4, 5});
    });
  });

  group('FEAT-11 Stitch citations', () {
    test('Classes Coming soon cites EN + AR Stitch ids', () {
      expect(
        ClassesComingSoonPage.stitchScreenIdEn,
        'c3b2a1416ebb4f46a71aa108f418e51c',
      );
      expect(
        ClassesComingSoonPage.stitchScreenIdAr,
        '747d13fbf3b741d09c3a29e18d7b0bd4',
      );
    });

    test('Reports Coming soon cites EN + AR Stitch ids', () {
      expect(
        ReportsComingSoonPage.stitchScreenIdEn,
        'ace7bf6e830b4e9f8963cfa5dd07909b',
      );
      expect(
        ReportsComingSoonPage.stitchScreenIdAr,
        '82188fd0c27a4baa923ead6221e04d7b',
      );
    });

    test('Staff invite cites Staff Management Stitch id', () {
      expect(
        StaffInviteScreen.stitchScreenId,
        'dcc070ef2b1e45058b3e042ad70140e3',
      );
    });

    test('Kinetic tokens remain charcoal / lime (no purple)', () {
      expect(KineticTokens.deepCharcoal, const Color(0xFF121212));
      expect(KineticTokens.electricLime, const Color(0xFFCCFF00));
    });
  });

  group('FEAT-11 Coming soon widget smoke', () {
    testWidgets('Classes empty renders EN copy', (tester) async {
      await pumpLocalizedApp(
        tester,
        const ClassesComingSoonPage(),
        waitFor: find.text('Classes — Coming Soon'),
      );

      expect(find.text('Classes — Coming Soon'), findsOneWidget);
      expect(
        find.textContaining('No schedule management'),
        findsOneWidget,
      );
      expect(find.byType(DataTable), findsNothing);
      expect(find.byType(CalendarDatePicker), findsNothing);
    });

    testWidgets('Classes empty renders AR copy (RTL)', (tester) async {
      await pumpLocalizedApp(
        tester,
        const ClassesComingSoonPage(),
        locale: AppLocales.ar,
        waitFor: find.text('الحصص — قريبًا'),
      );

      expect(find.text('الحصص — قريبًا'), findsOneWidget);
    });

    testWidgets('Reports empty renders EN copy + hint', (tester) async {
      await pumpLocalizedApp(
        tester,
        const ReportsComingSoonPage(),
        waitFor: find.text('Reports — Coming Soon'),
      );

      expect(find.text('Reports — Coming Soon'), findsOneWidget);
      expect(find.text('Attendance & revenue soon'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(find.byType(DataTable), findsNothing);
    });

    testWidgets('Reports empty renders AR copy', (tester) async {
      await pumpLocalizedApp(
        tester,
        const ReportsComingSoonPage(),
        locale: AppLocales.ar,
        waitFor: find.text('التقارير — قريبًا'),
      );

      expect(find.text('التقارير — قريبًا'), findsOneWidget);
      expect(find.text('الحضور والإيرادات قريبًا'), findsOneWidget);
    });
  });
}
