import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fithub_portal_admin/features/access_scanner/domain/entities/member_roster_entry.dart';
import 'package:fithub_portal_admin/features/auth/domain/entities/employee_profile.dart';
import 'package:fithub_portal_admin/features/members/presentation/cubit/member_roster_cubit.dart';
import 'package:fithub_portal_admin/features/members/presentation/fixtures/members_stitch_fixtures.dart';
import 'package:fithub_portal_admin/features/members/presentation/screens/member_management_screen.dart';
import 'package:fithub_portal_admin/features/memberships/domain/entities/freeze_policy.dart';
import 'package:fithub_portal_admin/features/memberships/domain/entities/membership_plan.dart';
import 'package:fithub_portal_admin/features/memberships/domain/repositories/memberships_repository.dart';
import 'package:fithub_portal_admin/features/memberships/domain/use_cases/memberships_use_cases.dart';
import 'package:fithub_portal_admin/features/memberships/presentation/cubit/memberships_cubit.dart';
import 'package:fithub_portal_admin/features/memberships/presentation/widgets/freeze_policy_settings_section.dart';
import 'package:mocktail/mocktail.dart';

import 'support/localized_pump.dart';

class _MockMembershipsCubit extends Mock implements MembershipsCubit {}

class _MockMemberRosterCubit extends Mock implements MemberRosterCubit {}

class _MockRepo extends Mock implements MembershipsRepository {}

MembershipsCubit _buildCubit(_MockRepo repo) {
  return MembershipsCubit(
    listPlans: ListMembershipPlansUseCase(repo),
    createPlan: CreateMembershipPlanUseCase(repo),
    deactivatePlan: DeactivateMembershipPlanUseCase(repo),
    assignMembership: AssignMembershipUseCase(repo),
    listAthletes: ListMembershipAthletesUseCase(repo),
    renewMembership: RenewMembershipUseCase(repo),
    freezeMembership: FreezeMembershipUseCase(repo),
    unfreezeMembership: UnfreezeMembershipUseCase(repo),
    listFreezePolicies: ListFreezePoliciesUseCase(repo),
    upsertFreezePolicy: UpsertFreezePolicyUseCase(repo),
  );
}

void main() {
  group('FEAT-61 role gates', () {
    test('Admin renew+freeze; Receptionist freeze only', () {
      const admin = EmployeeProfile(
        id: '1',
        tenantId: 't1',
        userId: 'u1',
        name: 'A',
        role: 'Admin',
      );
      const receptionist = EmployeeProfile(
        id: '2',
        tenantId: 't1',
        userId: 'u2',
        name: 'R',
        role: 'Receptionist',
      );
      expect(admin.canRenewMembership, isTrue);
      expect(admin.canFreezeMembership, isTrue);
      expect(admin.canManageFreezePolicy, isTrue);
      expect(receptionist.canRenewMembership, isFalse);
      expect(receptionist.canFreezeMembership, isTrue);
      expect(receptionist.canManageFreezePolicy, isFalse);
    });
  });

  group('FEAT-61 plan chip (exact name)', () {
    test('no Elite/Standard/Basic keyword remapping', () {
      expect(membersPlanChipLabel('Elite Monthly'), 'Elite Monthly');
      expect(membersPlanChipLabel('Gold Pass'), 'Gold Pass');
      expect(membersPlanChipLabel(null), '—');
      expect(membersPlanChipKind('Elite'), MembersPlanChipKind.named);
      expect(membersPlanChipKind('Basic Day'), MembersPlanChipKind.named);
      expect(membersPlanChipKind(null), MembersPlanChipKind.none);
    });

    test('resolveFreezePolicy prefers per-plan over general', () {
      const general = FreezePolicy(
        id: 'g',
        tenantId: 't1',
        freezeDays: 3,
        maxFreezeDaysPerTime: 7,
      );
      const perPlan = FreezePolicy(
        id: 'p',
        tenantId: 't1',
        planId: 'plan-1',
        freezeDays: 5,
        maxFreezeDaysPerTime: 14,
      );
      expect(
        resolveFreezePolicy([general, perPlan], 'plan-1')?.id,
        'p',
      );
      expect(
        resolveFreezePolicy([general, perPlan], 'other')?.id,
        'g',
      );
      expect(resolveFreezePolicy(const [], 'plan-1'), isNull);
    });
  });

  group('FEAT-61 MembershipsCubit ops', () {
    late _MockRepo repository;

    setUp(() {
      repository = _MockRepo();
      when(() => repository.listPlans(activeOnly: any(named: 'activeOnly')))
          .thenAnswer((_) async => const []);
      when(() => repository.listEnrolledAthletes())
          .thenAnswer((_) async => const []);
      when(() => repository.listFreezePolicies())
          .thenAnswer((_) async => const []);
    });

    test('renewMembership returns success key', () async {
      when(() => repository.renewMembership(any()))
          .thenAnswer((_) async => 'new-id');
      final cubit = _buildCubit(repository);
      final key = await cubit.renewMembership('m1');
      expect(key, 'members.success.renewed');
      await cubit.close();
    });

    test('freezeMembership returns success key', () async {
      when(
        () => repository.freezeMembership(
          membershipId: any(named: 'membershipId'),
          days: any(named: 'days'),
        ),
      ).thenAnswer((_) async => 'm1');
      final cubit = _buildCubit(repository);
      final key = await cubit.freezeMembership(membershipId: 'm1', days: 5);
      expect(key, 'members.success.frozen');
      await cubit.close();
    });

    test('upsertFreezePolicy validates max >= 1 and freeze <= max', () async {
      when(
        () => repository.upsertFreezePolicy(
          freezeDays: any(named: 'freezeDays'),
          maxFreezeDaysPerTime: any(named: 'maxFreezeDaysPerTime'),
          planId: any(named: 'planId'),
        ),
      ).thenAnswer((_) async => 'pol-1');
      when(() => repository.listFreezePolicies()).thenAnswer(
        (_) async => const [
          FreezePolicy(
            id: 'pol-1',
            tenantId: 't1',
            freezeDays: 7,
            maxFreezeDaysPerTime: 14,
          ),
        ],
      );

      final cubit = _buildCubit(repository);
      final bad = await cubit.upsertFreezePolicy(
        freezeDays: 20,
        maxFreezeDaysPerTime: 14,
      );
      expect(bad, 'gym_settings.freeze.error.invalid');

      final ok = await cubit.upsertFreezePolicy(
        freezeDays: 7,
        maxFreezeDaysPerTime: 14,
      );
      expect(ok, 'gym_settings.freeze.success.saved');
      expect(cubit.state.freezePolicies, hasLength(1));
      await cubit.close();
    });
  });

  group('FEAT-61 Members roster actions', () {
    late _MockMembershipsCubit membershipsCubit;
    late _MockMemberRosterCubit rosterCubit;

    setUp(() {
      membershipsCubit = _MockMembershipsCubit();
      rosterCubit = _MockMemberRosterCubit();

      when(() => membershipsCubit.state).thenReturn(
        MembershipsState(
          status: MembershipsStatus.ready,
          freezePolicies: const [
            FreezePolicy(
              id: 'g',
              tenantId: 't1',
              freezeDays: 7,
              maxFreezeDaysPerTime: 14,
            ),
          ],
        ),
      );
      when(() => membershipsCubit.stream).thenAnswer(
        (_) => Stream.value(
          MembershipsState(
            status: MembershipsStatus.ready,
            freezePolicies: const [
              FreezePolicy(
                id: 'g',
                tenantId: 't1',
                freezeDays: 7,
                maxFreezeDaysPerTime: 14,
              ),
            ],
          ),
        ),
      );
      when(() => membershipsCubit.loadFreezePolicies()).thenAnswer((_) async {});

      final members = [
        MemberRosterEntry(
          id: 'a1',
          fullName: 'Ada',
          powerScore: 80,
          cryptoSalt: 'salt',
          createdAt: DateTime.utc(2026, 1, 1),
          membershipId: 'm1',
          membershipPlanId: 'p1',
          membershipPlanName: 'Gold Pass',
          membershipStatus: 'active',
        ),
      ];
      when(() => rosterCubit.state).thenReturn(
        MemberRosterState(
          status: MemberRosterStatus.ready,
          members: members,
        ),
      );
      when(() => rosterCubit.stream).thenAnswer(
        (_) => Stream.value(
          MemberRosterState(
            status: MemberRosterStatus.ready,
            members: members,
          ),
        ),
      );
    });

    testWidgets('exact plan name; Admin renew+freeze enabled', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await pumpLocalizedApp(
        tester,
        MultiBlocProvider(
          providers: [
            BlocProvider<MembershipsCubit>.value(value: membershipsCubit),
            BlocProvider<MemberRosterCubit>.value(value: rosterCubit),
          ],
          child: const MemberManagementScreen(
            canWrite: true,
            canRenew: true,
            canFreeze: true,
          ),
        ),
        waitFor: find.text('Gold Pass'),
      );

      expect(find.text('Gold Pass'), findsOneWidget);
      expect(find.text('ELITE'), findsNothing);
      expect(find.text('STANDARD'), findsNothing);

      final freeze = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'FREEZE'),
      );
      final renew = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'RENEW'),
      );
      expect(freeze.onPressed, isNotNull);
      expect(renew.onPressed, isNotNull);
    });

    testWidgets('Receptionist: freeze on, renew off', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await pumpLocalizedApp(
        tester,
        MultiBlocProvider(
          providers: [
            BlocProvider<MembershipsCubit>.value(value: membershipsCubit),
            BlocProvider<MemberRosterCubit>.value(value: rosterCubit),
          ],
          child: const MemberManagementScreen(
            canWrite: false,
            canRenew: false,
            canFreeze: true,
          ),
        ),
        waitFor: find.text('Gold Pass'),
      );

      final freeze = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'FREEZE'),
      );
      final renew = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'RENEW'),
      );
      expect(freeze.onPressed, isNotNull);
      expect(renew.onPressed, isNull);
    });
  });

  group('FEAT-61 Freeze policy settings section', () {
    late _MockRepo repository;

    setUp(() {
      repository = _MockRepo();
      when(() => repository.listPlans(activeOnly: any(named: 'activeOnly')))
          .thenAnswer(
            (_) async => const [
              MembershipPlan(
                id: 'p1',
                tenantId: 't1',
                name: 'Monthly',
                durationDays: 30,
                priceCents: 100,
                currency: 'EGP',
                isActive: true,
              ),
            ],
          );
      when(() => repository.listEnrolledAthletes())
          .thenAnswer((_) async => const []);
      when(() => repository.listFreezePolicies()).thenAnswer(
        (_) async => const [
          FreezePolicy(
            id: 'g',
            tenantId: 't1',
            freezeDays: 7,
            maxFreezeDaysPerTime: 14,
          ),
        ],
      );
    });

    testWidgets('renders Freeze policy heading EN', (tester) async {
      final cubit = _buildCubit(repository);
      await pumpLocalizedApp(
        tester,
        BlocProvider<MembershipsCubit>.value(
          value: cubit,
          child: const Scaffold(
            body: SingleChildScrollView(
              child: FreezePolicySettingsSection(canWrite: true),
            ),
          ),
        ),
        waitFor: find.text('FREEZE POLICY'),
      );
      expect(find.text('FREEZE POLICY'), findsOneWidget);
      expect(find.textContaining('Visual Spec Card'), findsOneWidget);
      expect(find.text('General (tenant-wide)'), findsOneWidget);
      await cubit.close();
    });
  });
}
