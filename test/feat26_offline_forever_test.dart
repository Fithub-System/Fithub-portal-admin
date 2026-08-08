import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fithub_portal_admin/config/theme/kinetic_tokens.dart';
import 'package:fithub_portal_admin/core/database/app_database.dart';
import 'package:fithub_portal_admin/core/network/cloud_mutation_guard.dart';
import 'package:fithub_portal_admin/features/access_scanner/domain/entities/member_roster_entry.dart';
import 'package:fithub_portal_admin/features/access_scanner/domain/repositories/member_roster_repository.dart';
import 'package:fithub_portal_admin/features/billing/domain/billing_failure.dart';
import 'package:fithub_portal_admin/features/billing/domain/entities/membership_charge.dart';
import 'package:fithub_portal_admin/features/billing/domain/repositories/billing_repository.dart';
import 'package:fithub_portal_admin/features/billing/domain/use_cases/billing_use_cases.dart';
import 'package:fithub_portal_admin/features/billing/presentation/cubit/billing_cubit.dart';
import 'package:fithub_portal_admin/features/class_sessions/domain/class_sessions_failure.dart';
import 'package:fithub_portal_admin/features/class_sessions/domain/repositories/class_sessions_repository.dart';
import 'package:fithub_portal_admin/features/class_sessions/domain/use_cases/class_sessions_use_cases.dart';
import 'package:fithub_portal_admin/features/connectivity/presentation/widgets/safe_mode_banner.dart';
import 'package:fithub_portal_admin/features/dashboard/data/datasources/gyms_occupancy_local_data_source.dart';
import 'package:fithub_portal_admin/features/dashboard/domain/entities/gym_occupancy.dart';
import 'package:fithub_portal_admin/features/dashboard/domain/repositories/gyms_occupancy_repository.dart';
import 'package:fithub_portal_admin/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:fithub_portal_admin/features/marketing/domain/marketing_failure.dart';
import 'package:fithub_portal_admin/features/marketing/domain/repositories/marketing_repository.dart';
import 'package:fithub_portal_admin/features/marketing/domain/use_cases/marketing_use_cases.dart';
import 'package:fithub_portal_admin/features/members/domain/use_cases/list_cached_member_roster_use_case.dart';
import 'package:fithub_portal_admin/features/members/presentation/cubit/member_roster_cubit.dart';
import 'package:fithub_portal_admin/features/offline_sync/data/data_sources/local/offline_sync_local_data_source.dart';
import 'package:fithub_portal_admin/features/offline_sync/domain/entities/pending_attendance.dart';
import 'package:fithub_portal_admin/features/staff_invite/domain/entities/staff_invite.dart';
import 'package:fithub_portal_admin/features/staff_invite/domain/entities/staff_role.dart';
import 'package:fithub_portal_admin/features/staff_invite/domain/repositories/staff_invite_repository.dart';
import 'package:fithub_portal_admin/features/staff_invite/domain/staff_invite_failure.dart';
import 'package:fithub_portal_admin/features/staff_invite/domain/use_cases/staff_invite_use_case.dart';
import 'package:mocktail/mocktail.dart';

import 'support/localized_pump.dart';

class _MockBillingRepo extends Mock implements BillingRepository {}

class _MockClassRepo extends Mock implements ClassSessionsRepository {}

class _MockMarketingRepo extends Mock implements MarketingRepository {}

class _MockInviteRepo extends Mock implements StaffInviteRepository {}

class _MockRosterRepo extends Mock implements MemberRosterRepository {}

class _MockGymsRepo extends Mock implements GymsOccupancyRepository {}

class _FakeLocal implements GymsOccupancyLocalDataSource {
  GymOccupancy? cached;

  @override
  Future<GymOccupancy?> readCached(String tenantId) async => cached;

  @override
  Future<void> writeCache(GymOccupancy occupancy) async {
    cached = occupancy;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(MembershipChargeStatus.paid);
    registerFallbackValue(DateTime.utc(2026, 1, 1));
    registerFallbackValue(
      const StaffInvite(email: 'a@b.c', role: StaffRole.admin, name: 'N'),
    );
  });

  group('FEAT-26 SafeMode banner', () {
    testWidgets('visible banner reuses Phase 1.3 zinc strip + EN copy', (
      tester,
    ) async {
      await pumpLocalizedApp(
        tester,
        const Scaffold(body: SafeModeBanner(visible: true)),
        waitFor: find.text('Pulse SafeMode: data is saved locally'),
      );

      expect(find.text('Pulse SafeMode: data is saved locally'), findsOneWidget);
      final bannerSize = tester.getSize(
        find.byKey(const ValueKey('safe-mode-on')),
      );
      expect(bannerSize.height, KineticTokens.safeModeBannerHeight);
      final banner = tester.widget<Container>(
        find.byKey(const ValueKey('safe-mode-on')),
      );
      expect(banner.color, KineticTokens.zincGray);
    });

    testWidgets('AR SafeMode banner copy localizes', (tester) async {
      await pumpLocalizedApp(
        tester,
        const Scaffold(body: SafeModeBanner(visible: true)),
        locale: const Locale('ar'),
        waitFor: find.textContaining('وضع الأمان'),
      );
      expect(find.textContaining('وضع الأمان'), findsOneWidget);
    });
  });

  group('FEAT-26 attendance queue gate', () {
    test('pending Drift rows survive with is_synced=false', () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      const tenantId = '11111111-1111-1111-1111-111111111111';
      const athleteId = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
      await database.seedPendingAttendance(
        PendingAttendance(
          id: 'log-feat26',
          tenantId: tenantId,
          athleteId: athleteId,
          checkedInAt: DateTime.utc(2026, 8, 8, 10),
        ),
      );

      final pending = await database.pendingAttendance();
      expect(pending, hasLength(1));
      expect(pending.single.isSynced, isFalse);

      // Explicit companion path (scan enqueue contract).
      await database.enqueueAttendance(
        LocalAttendanceQueueCompanion.insert(
          id: 'log-feat26-b',
          tenantId: tenantId,
          athleteId: athleteId,
          checkedInAt: DateTime.utc(2026, 8, 8, 11),
          isSynced: const Value(false),
        ),
      );
      final again = await database.pendingAttendance();
      expect(again.where((r) => !r.isSynced), hasLength(2));
    });
  });

  group('FEAT-26 cloud mutation offline deny', () {
    test('billing mark paid denied offline — no remote call', () async {
      final repo = _MockBillingRepo();
      final cubit = BillingCubit(
        listCharges: ListMembershipChargesUseCase(repo),
        updateStatus: UpdateMembershipChargeStatusUseCase(
          repo,
          cloudGuard: CloudMutationGuard(isOnline: () => false),
        ),
        applyFreeze: ApplyBillingFreezeUseCase(
          repo,
          cloudGuard: CloudMutationGuard(isOnline: () => false),
        ),
      );

      await cubit.markStatus(
        chargeId: 'c1',
        status: MembershipChargeStatus.paid,
      );
      expect(cubit.state.messageKey, 'billing.error.offline');
      verifyNever(
        () => repo.updateChargeStatus(
          chargeId: any(named: 'chargeId'),
          status: any(named: 'status'),
        ),
      );
      await cubit.close();
    });

    test('class upsert denied offline', () async {
      final repo = _MockClassRepo();
      final useCase = UpsertClassSessionUseCase(
        repo,
        cloudGuard: CloudMutationGuard(isOnline: () => false),
      );
      expect(
        () => useCase(
          title: 'Yoga',
          startsAt: DateTime(2026, 8, 8, 9),
          endsAt: DateTime(2026, 8, 8, 10),
          capacity: 10,
        ),
        throwsA(isA<ClassSessionsOfflineFailure>()),
      );
      verifyNever(
        () => repo.upsertSession(
          id: any(named: 'id'),
          title: any(named: 'title'),
          startsAt: any(named: 'startsAt'),
          endsAt: any(named: 'endsAt'),
          capacity: any(named: 'capacity'),
          coachEmployeeId: any(named: 'coachEmployeeId'),
          status: any(named: 'status'),
        ),
      );
    });

    test('marketing upsert denied offline', () async {
      final repo = _MockMarketingRepo();
      final campaign = UpsertMarketingCampaignUseCase(
        repo,
        cloudGuard: CloudMutationGuard(isOnline: () => false),
      );
      final promo = UpsertPromoCodeUseCase(
        repo,
        cloudGuard: CloudMutationGuard(isOnline: () => false),
      );

      expect(
        () => campaign(
          name: 'Flash',
          startsAt: DateTime.utc(2026, 8, 8),
          endsAt: DateTime.utc(2026, 8, 9),
          pushEnabled: false,
        ),
        throwsA(isA<MarketingOfflineFailure>()),
      );
      expect(
        () => promo(code: 'SAVE10', percentOff: 10),
        throwsA(isA<MarketingOfflineFailure>()),
      );
    });

    test('staff invite denied offline', () async {
      final repo = _MockInviteRepo();
      final useCase = InviteStaffUseCase(
        repo,
        cloudGuard: CloudMutationGuard(isOnline: () => false),
      );
      expect(
        () => useCase(
          const StaffInvite(
            email: 'coach@gym.com',
            role: StaffRole.coach,
            name: 'Ada',
          ),
        ),
        throwsA(isA<StaffInviteOfflineFailure>()),
      );
      verifyNever(() => repo.inviteStaff(any()));
    });

    test('offline failure keys are explicit (never silent success)', () {
      expect(const BillingOfflineFailure().messageKey, 'billing.error.offline');
      expect(
        CloudMutationGuard.deniedMessageKey,
        'connectivity.cloud_required.denied',
      );
    });
  });

  group('FEAT-26 cached roster / occupancy offline indicator', () {
    test('dashboard emits offline status from cache when offline', () async {
      final local = _FakeLocal()
        ..cached = const GymOccupancy(
          id: 't1',
          name: 'Pulse',
          currentOccupancy: 12,
          capacityLimit: 100,
        );
      final gyms = _MockGymsRepo();
      final connectivity = StreamController<bool>.broadcast();
      addTearDown(connectivity.close);

      final cubit = DashboardCubit(
        local: local,
        gymsRepository: gyms,
        tenantId: 't1',
        isOnline: () => false,
        onConnectivityChanged: connectivity.stream,
      );
      await cubit.start();
      expect(cubit.state.currentOccupancy, 12);
      expect(cubit.state.source, OccupancySource.cache);
      expect(cubit.state.statusMessageKey, 'dashboard.status.offline');
      await cubit.close();
    });

    test('member roster flags showingCachedOffline when offline', () async {
      final roster = _MockRosterRepo();
      when(
        () => roster.listCachedMembers(tenantId: any(named: 'tenantId')),
      ).thenAnswer(
        (_) async => [
          MemberRosterEntry(
            id: 'a1',
            fullName: 'Ada',
            powerScore: 10,
            cryptoSalt: 'salt',
            createdAt: DateTime.utc(2026, 1, 1),
            membershipStatus: 'active',
          ),
        ],
      );

      final cubit = MemberRosterCubit(
        listCachedRoster: ListCachedMemberRosterUseCase(roster),
        tenantId: 't1',
        isOnline: () => false,
      );
      await cubit.load();
      expect(cubit.state.showingCachedOffline, isTrue);
      expect(cubit.state.members, hasLength(1));
      await cubit.close();
    });
  });

  group('FEAT-26 i18n keys present', () {
    test('EN/AR cloud_required + feature offline keys exist', () {
      final en = json.decode(
        File('assets/translations/en.json').readAsStringSync(),
      ) as Map<String, dynamic>;
      final ar = json.decode(
        File('assets/translations/ar.json').readAsStringSync(),
      ) as Map<String, dynamic>;

      expect(en['connectivity']['cloud_required']['denied'], isA<String>());
      expect(ar['connectivity']['cloud_required']['denied'], isA<String>());
      expect(en['billing']['error']['offline'], isA<String>());
      expect(ar['billing']['error']['offline'], isA<String>());
      expect(en['classes']['error']['offline'], isA<String>());
      expect(en['marketing']['error']['offline'], isA<String>());
      expect(en['staff_invite']['error']['offline'], isA<String>());
      expect(en['members']['status']['offline_stale'], isA<String>());
      expect(en['members']['footer']['sync_offline'], isA<String>());
      expect(ar['members']['status']['offline_stale'], isA<String>());
    });
  });
}
