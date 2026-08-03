import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fithub_portal_admin/config/theme/kinetic_tokens.dart';
import 'package:fithub_portal_admin/features/dashboard/presentation/widgets/access_gate_panel.dart';
import 'package:fithub_portal_admin/features/dashboard/presentation/widgets/admin_overview_dashboard.dart';
import 'package:fithub_portal_admin/features/dashboard/presentation/widgets/daily_yield_card.dart';
import 'package:fithub_portal_admin/features/dashboard/presentation/widgets/expiring_memberships_card.dart';
import 'package:fithub_portal_admin/features/dashboard/presentation/widgets/live_occupancy_gauge.dart';
import 'package:fithub_portal_admin/features/dashboard/presentation/widgets/overview_footer_stats.dart';
import 'package:fithub_portal_admin/features/home/presentation/pages/portal_shell_destinations.dart';

import 'support/localized_pump.dart';

void main() {
  group('FEAT-16 VF1 Overview citations', () {
    test('Overview cites locked Admin Overview screen id', () {
      expect(
        AdminOverviewDashboard.stitchScreenId,
        '216e0407184f4c39bd501ed436c1e88b',
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
  });

  group('FEAT-16 VF1 Overview regions', () {
    testWidgets('desktop-wide layout shows Stitch region labels', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1400, 1200));
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

      await tester.tap(find.byKey(const Key('home-open-scanner-cta')));
      await tester.pump();
      expect(opened, isTrue);
    });

    testWidgets('approved scan shows Access Granted chrome', (tester) async {
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
            lastScanMemberName: 'John Smith',
          ),
        ),
        waitFor: find.text('ACCESS GRANTED'),
      );

      expect(find.text('John Smith'), findsOneWidget);
      expect(find.text('ACCESS GRANTED'), findsOneWidget);
      expect(find.text('ACTIVE MEMBER'), findsOneWidget);
    });
  });
}
