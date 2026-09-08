import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fithub_portal_admin/config/theme/kinetic_tokens.dart';
import 'package:fithub_portal_admin/features/access_scanner/domain/entities/member_roster_entry.dart';
import 'package:fithub_portal_admin/features/access_scanner/domain/repositories/member_roster_repository.dart';
import 'package:fithub_portal_admin/features/dashboard/data/datasources/overview_metrics_remote_data_source.dart';
import 'package:fithub_portal_admin/features/dashboard/data/repositories/overview_home_metrics_repository_impl.dart';
import 'package:fithub_portal_admin/features/dashboard/domain/entities/overview_expiring_row.dart';
import 'package:fithub_portal_admin/features/dashboard/domain/entities/overview_home_metrics.dart';
import 'package:fithub_portal_admin/features/dashboard/presentation/fixtures/overview_stitch_fixtures.dart';
import 'package:fithub_portal_admin/features/dashboard/presentation/widgets/admin_overview_dashboard.dart';
import 'package:fithub_portal_admin/features/dashboard/presentation/widgets/daily_yield_card.dart';
import 'package:fithub_portal_admin/features/dashboard/presentation/widgets/expiring_memberships_card.dart';
import 'package:fithub_portal_admin/features/dashboard/presentation/widgets/overview_footer_stats.dart';

import 'support/localized_pump.dart';

class _FakeRoster implements MemberRosterRepository {
  _FakeRoster(this.members);

  final List<MemberRosterEntry> members;

  @override
  Future<int> countCachedMembers({required String tenantId}) async =>
      members.length;

  @override
  Future<List<MemberRosterEntry>> listCachedMembers({
    required String tenantId,
  }) async =>
      members;

  @override
  Future<int> syncRoster({required String tenantId}) async => members.length;
}

class _FakeRemote implements OverviewMetricsRemoteDataSource {
  _FakeRemote({this.checkIns = 0, this.paidCents = 0, this.currency = 'EGP'});

  final int checkIns;
  final int paidCents;
  final String currency;

  @override
  Future<int> countCheckInsSince({
    required String tenantId,
    required DateTime dayStartUtc,
  }) async =>
      checkIns;

  @override
  Future<({int totalCents, String currency})> sumPaidChargesSince({
    required String tenantId,
    required DateTime dayStartUtc,
  }) async =>
      (totalCents: paidCents, currency: currency);
}

void main() {
  group('FEAT-60 OverviewHomeMetrics', () {
    test(r'formats revenue as CURRENCY amount (no invented USD $ for EGP)', () {
      const metrics = OverviewHomeMetrics(
        membersCount: 0,
        checkInsToday: 0,
        revenueTodayCents: 0,
        revenueCurrency: 'EGP',
        expiringSoon: [],
      );
      expect(metrics.revenueAmountLabel, 'EGP 0');
      expect(metrics.membersCountLabel, '0');
      expect(metrics.checkInsTodayLabel, '0');
    });

    test('repository maps empty live + guest-unrelated counts honestly', () async {
      final repo = OverviewHomeMetricsRepositoryImpl(
        memberRosterRepository: _FakeRoster(const []),
        remote: _FakeRemote(),
        clock: () => DateTime.utc(2026, 9, 8, 12),
      );
      final metrics = await repo.load(tenantId: 't1');
      expect(metrics.membersCount, 0);
      expect(metrics.checkInsToday, 0);
      expect(metrics.revenueTodayCents, 0);
      expect(metrics.expiringSoon, isEmpty);
    });

    test('repository filters expiring within 48h window', () async {
      final now = DateTime.utc(2026, 9, 8, 12);
      final members = [
        MemberRosterEntry(
          id: 'a1',
          fullName: 'Ava Chen',
          powerScore: 100,
          cryptoSalt: 'salt',
          createdAt: now,
          membershipStatus: 'active',
          membershipPlanName: 'Elite',
          membershipEndsAt: now.add(const Duration(hours: 20)),
        ),
        MemberRosterEntry(
          id: 'a2',
          fullName: 'Far Away',
          powerScore: 100,
          cryptoSalt: 'salt',
          createdAt: now,
          membershipStatus: 'active',
          membershipPlanName: 'Basic',
          membershipEndsAt: now.add(const Duration(hours: 72)),
        ),
      ];
      final repo = OverviewHomeMetricsRepositoryImpl(
        memberRosterRepository: _FakeRoster(members),
        remote: _FakeRemote(checkIns: 3, paidCents: 125000, currency: 'EGP'),
        clock: () => now,
      );
      final metrics = await repo.load(tenantId: 't1');
      expect(metrics.membersCount, 2);
      expect(metrics.checkInsToday, 3);
      expect(metrics.revenueTodayCents, 125000);
      expect(metrics.revenueAmountLabel, 'EGP 1,250');
      expect(metrics.expiringSoon, hasLength(1));
      expect(metrics.expiringSoon.first.fullName, 'Ava Chen');
      expect(metrics.expiringSoon.first.urgent, isTrue);
    });
  });

  group('FEAT-60 live Overview honesty', () {
    testWidgets('empty live binds — no Marcus/Elena / no \$12,482 / guest fixture', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1400, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await pumpLocalizedApp(
        tester,
        Scaffold(
          backgroundColor: KineticTokens.stitchBackground,
          body: AdminOverviewDashboard(
            currentOccupancy: 0,
            capacityLimit: 40,
            onOpenScanner: () {},
            liveMetricsBound: true,
            metricsLoading: false,
            revenueAmountLabel: 'EGP 0',
            expiringRows: const [],
            membersCountLabel: '0',
            checkInsTodayLabel: '0',
          ),
        ),
        waitFor: find.byKey(AdminOverviewDashboard.insightsRowKey),
      );

      expect(find.text(r'$12,482'), findsNothing);
      expect(find.text('+14.2% vs yesterday'), findsNothing);
      expect(find.text('Marcus Thorne'), findsNothing);
      expect(find.text('Elena Rodriguez'), findsNothing);
      expect(find.text('2,841'), findsNothing);
      expect(find.text('42'), findsNothing);
      expect(find.text('EGP 0'), findsOneWidget);
      expect(find.byKey(const Key('overview-expiring-empty')), findsOneWidget);
      expect(find.byKey(const Key('overview-yield-delta-omitted')), findsOneWidget);
      // Guest fixture retained
      expect(find.text(OverviewStitchFixtures.guestPasses), findsOneWidget);
      expect(find.text('CHECK-INS TODAY'), findsOneWidget);
      expect(find.text('0'), findsWidgets);
    });

    testWidgets('layout order: Hero → Insights → Mid (Expiring|Gate)', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1400, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await pumpLocalizedApp(
        tester,
        Scaffold(
          body: AdminOverviewDashboard(
            currentOccupancy: 1,
            capacityLimit: 10,
            onOpenScanner: () {},
            liveMetricsBound: true,
            revenueAmountLabel: 'EGP 0',
            expiringRows: const [],
            membersCountLabel: '1',
            checkInsTodayLabel: '2',
          ),
        ),
        waitFor: find.byKey(AdminOverviewDashboard.midRowKey),
      );

      final hero = tester.getTopLeft(
        find.byKey(AdminOverviewDashboard.heroRowKey),
      );
      final insights = tester.getTopLeft(
        find.byKey(AdminOverviewDashboard.insightsRowKey),
      );
      final mid = tester.getTopLeft(find.byKey(AdminOverviewDashboard.midRowKey));

      expect(hero.dy < insights.dy, isTrue);
      expect(insights.dy < mid.dy, isTrue);
      expect(find.byType(OverviewFooterStats), findsOneWidget);
      expect(find.byType(ExpiringMembershipsCard), findsOneWidget);
      expect(find.byType(DailyYieldCard), findsOneWidget);
    });

    testWidgets('live expiring row renders without fixture fallback', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1400, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await pumpLocalizedApp(
        tester,
        Scaffold(
          body: AdminOverviewDashboard(
            currentOccupancy: 1,
            capacityLimit: 10,
            onOpenScanner: () {},
            liveMetricsBound: true,
            revenueAmountLabel: 'EGP 50',
            membersCountLabel: '4',
            checkInsTodayLabel: '1',
            expiringRows: const [
              OverviewExpiringRow(
                fullName: 'Live Member',
                email: '—',
                planLabel: 'ELITE',
                expirationDate: 'Sep 9, 2026',
                relativeLabel: 'Tomorrow',
                urgent: true,
              ),
            ],
          ),
        ),
        waitFor: find.text('Live Member'),
      );

      expect(find.text('Live Member'), findsOneWidget);
      expect(find.text('Marcus Thorne'), findsNothing);
      expect(find.text('EGP 50'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('1'), findsWidgets);
    });
  });

  group('FEAT-60 unbound chrome still fixtures (VF1-R)', () {
    testWidgets('null live props keep Stitch samples', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await pumpLocalizedApp(
        tester,
        Scaffold(
          body: AdminOverviewDashboard(
            currentOccupancy: 80,
            capacityLimit: 100,
            onOpenScanner: () {},
          ),
        ),
        waitFor: find.text(r'$12,482'),
      );

      expect(find.text(r'$12,482'), findsOneWidget);
      expect(find.text('Marcus Thorne'), findsOneWidget);
      expect(find.text('2,841'), findsOneWidget);
      expect(find.text('CHECK-INS TODAY'), findsOneWidget);
    });
  });
}
