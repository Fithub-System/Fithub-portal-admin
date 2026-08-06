import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fithub_portal_admin/config/theme/kinetic_tokens.dart';
import 'package:fithub_portal_admin/features/dashboard/presentation/fixtures/overview_stitch_fixtures.dart';
import 'package:fithub_portal_admin/features/dashboard/presentation/widgets/access_gate_panel.dart';
import 'package:fithub_portal_admin/features/dashboard/presentation/widgets/admin_overview_dashboard.dart';
import 'package:fithub_portal_admin/features/dashboard/presentation/widgets/daily_yield_card.dart';
import 'package:fithub_portal_admin/features/dashboard/presentation/widgets/expiring_memberships_card.dart';
import 'package:fithub_portal_admin/features/dashboard/presentation/widgets/live_occupancy_gauge.dart';
import 'package:fithub_portal_admin/features/dashboard/presentation/widgets/overview_footer_stats.dart';
import 'package:fithub_portal_admin/features/home/presentation/pages/portal_shell_destinations.dart';

import 'support/localized_pump.dart';

void main() {
  group('FEAT-16 VF1 / VF1-R Overview citations', () {
    test('Overview cites locked Admin Overview screen id', () {
      expect(
        AdminOverviewDashboard.stitchScreenId,
        '216e0407184f4c39bd501ed436c1e88b',
      );
      expect(
        OverviewStitchFixtures.stitchScreenId,
        AdminOverviewDashboard.stitchScreenId,
      );
      expect(
        KineticTokens.stitchOccupancyScreenId,
        AdminOverviewDashboard.stitchScreenId,
      );
      expect(KineticTokens.railWidth, 256);
      expect(KineticTokens.primaryContainer.toARGB32(), 0xFFC3F400);
      expect(KineticTokens.onPrimaryContainer.toARGB32(), 0xFF556D00);
      expect(KineticTokens.surfaceContainerLowest.toARGB32(), 0xFF0E0E0E);
    });

    test('Install 6-rail destinations unchanged', () {
      expect(PortalShellDestinations.destinationCount, 6);
      expect(PortalShellDestinations.home, 0);
    });

    test('§4.1 fixture constants match Stitch artboard', () {
      expect(OverviewStitchFixtures.yieldAmount, r'$12,482');
      expect(OverviewStitchFixtures.yieldDelta, '+14.2% vs yesterday');
      expect(OverviewStitchFixtures.expiringRows, hasLength(2));
      expect(OverviewStitchFixtures.expiringRows.first.fullName, 'Marcus Thorne');
      expect(
        OverviewStitchFixtures.expiringRows.last.fullName,
        'Elena Rodriguez',
      );
      expect(OverviewStitchFixtures.totalActive, '2,841');
      expect(OverviewStitchFixtures.classesToday, '42');
      expect(OverviewStitchFixtures.guestPasses, '12');
      expect(OverviewStitchFixtures.incidentReports, '0');
      expect(OverviewStitchFixtures.grantedMemberName, 'John Smith');
      expect(OverviewStitchFixtures.grantedMemberId, '#KM-88219');
    });
  });

  group('FEAT-16 VF1 / VF1-R Overview regions', () {
    testWidgets('desktop-wide layout ships §4.1 fixtures — never bare —', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1400, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      var opened = false;
      await pumpLocalizedApp(
        tester,
        Scaffold(
          backgroundColor: KineticTokens.stitchBackground,
          body: AdminOverviewDashboard(
            currentOccupancy: 80,
            capacityLimit: 100,
            onOpenScanner: () => opened = true,
          ),
        ),
        waitFor: find.text('LIVE OCCUPANCY'),
      );

      expect(find.byType(LiveOccupancyGauge), findsOneWidget);
      expect(find.byType(DailyYieldCard), findsOneWidget);
      expect(find.byType(ExpiringMembershipsCard), findsOneWidget);
      expect(find.byType(AccessGatePanel), findsOneWidget);
      expect(find.byType(OverviewFooterStats), findsOneWidget);
      expect(find.textContaining('YIELD'), findsWidgets);
      expect(find.text('EXPIRING MEMBERSHIPS'), findsOneWidget);
      expect(find.text('ACCESS GATE 1'), findsOneWidget);
      expect(find.text('TOTAL ACTIVE'), findsOneWidget);
      expect(find.text('WAITING FOR SCAN...'), findsOneWidget);

      // §4.1 content fixtures
      expect(find.text(r'$12,482'), findsOneWidget);
      expect(find.text('+14.2% vs yesterday'), findsOneWidget);
      expect(find.text('Marcus Thorne'), findsOneWidget);
      expect(find.text('Elena Rodriguez'), findsOneWidget);
      expect(find.text('ELITE PERFORMANCE'), findsOneWidget);
      expect(find.text('FOUNDRY BASIC'), findsOneWidget);
      expect(find.text('2,841'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('John Smith'), findsOneWidget);
      expect(find.text('ACCESS GRANTED'), findsOneWidget);
      expect(find.textContaining('KM-88219'), findsOneWidget);

      // No bare em-dash shells in unbound regions
      expect(find.text('—'), findsNothing);

      await tester.tap(find.byKey(const Key('home-open-scanner-cta')));
      await tester.pump();
      expect(opened, isTrue);
    });

    testWidgets('live approved scan replaces Access Granted sample name', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await pumpLocalizedApp(
        tester,
        Scaffold(
          body: AdminOverviewDashboard(
            currentOccupancy: 12,
            capacityLimit: 40,
            onOpenScanner: () {},
            lastScanApproved: true,
            lastScanMemberName: 'Ava Chen',
          ),
        ),
        waitFor: find.text('ACCESS GRANTED'),
      );

      expect(find.text('Ava Chen'), findsOneWidget);
      expect(find.text('John Smith'), findsNothing);
      expect(find.text('ACCESS GRANTED'), findsOneWidget);
      expect(find.text('ACTIVE MEMBER'), findsOneWidget);
      expect(find.text('—'), findsNothing);
    });
  });
}
