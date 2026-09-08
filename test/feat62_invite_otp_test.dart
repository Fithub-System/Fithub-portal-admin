import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fithub_portal_admin/core/network/app_endpoints.dart';
import 'package:fithub_portal_admin/core/network/cloud_mutation_guard.dart';
import 'package:fithub_portal_admin/features/add_member/domain/add_member_failure.dart';
import 'package:fithub_portal_admin/features/add_member/domain/entities/member_invite.dart';
import 'package:fithub_portal_admin/features/add_member/domain/repositories/add_member_repository.dart';
import 'package:fithub_portal_admin/features/add_member/domain/use_cases/add_member_use_cases.dart';
import 'package:fithub_portal_admin/features/add_member/presentation/bloc/add_member_bloc.dart';
import 'package:fithub_portal_admin/features/add_member/presentation/screens/add_member_screen.dart';
import 'package:fithub_portal_admin/features/auth/domain/entities/employee_profile.dart';
import 'package:fithub_portal_admin/features/memberships/domain/entities/membership_plan.dart';
import 'package:fithub_portal_admin/features/memberships/domain/repositories/memberships_repository.dart';
import 'package:fithub_portal_admin/features/memberships/domain/use_cases/memberships_use_cases.dart';
import 'package:mocktail/mocktail.dart';

import 'support/localized_pump.dart';

class _MockAddMemberRepo extends Mock implements AddMemberRepository {}

class _MockMembershipsRepo extends Mock implements MembershipsRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(const MemberInvite(email: 'fallback@example.com'));
  });

  group('FEAT-62 endpoints + Admin gate', () {
    test('inviteMember Edge path is functions/v1/invite-member', () {
      expect(
        AppEndpoints.inviteMember,
        contains('/functions/v1/invite-member'),
      );
    });

    test('Admin can enroll/invite; Receptionist cannot', () {
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
      expect(admin.canEnrollMembers, isTrue);
      expect(receptionist.canEnrollMembers, isFalse);
    });

    test('Add Member Stitch G4 ids locked', () {
      expect(
        AddMemberScreen.stitchScreenIdEn,
        'cd59a129a24449478a5249ccb41635fb',
      );
      expect(
        AddMemberScreen.stitchScreenIdAr,
        '89fe5d7afb8d4d4384d7e6498bcdd065',
      );
    });
  });

  group('InviteMemberUseCase', () {
    late _MockAddMemberRepo repo;
    late InviteMemberUseCase useCase;

    setUp(() {
      repo = _MockAddMemberRepo();
      useCase = InviteMemberUseCase(
        repo,
        cloudGuard: CloudMutationGuard(isOnline: () => true),
      );
      when(() => repo.inviteMember(any())).thenAnswer(
        (_) async => const MemberInviteResult(
          inviteId: 'inv-1',
          email: 'a@example.com',
          tenantId: 't1',
          message: 'ok',
        ),
      );
    });

    test('email path normalizes and forwards plan/display', () async {
      await useCase(
        identifier: '  Ada@Example.COM ',
        displayName: ' Ada ',
        planId: 'p1',
      );
      final captured =
          verify(() => repo.inviteMember(captureAny())).captured.single
              as MemberInvite;
      expect(captured.email, 'ada@example.com');
      expect(captured.username, isNull);
      expect(captured.displayName, 'Ada');
      expect(captured.planId, 'p1');
    });

    test('username path does not treat as email', () async {
      await useCase(identifier: 'coolathlete');
      final captured =
          verify(() => repo.inviteMember(captureAny())).captured.single
              as MemberInvite;
      expect(captured.username, 'coolathlete');
      expect(captured.email, isNull);
    });

    test('empty identifier → validation', () async {
      await expectLater(
        () => useCase(identifier: '  '),
        throwsA(isA<AddMemberValidationFailure>()),
      );
    });

    test('offline → AddMemberOfflineFailure', () async {
      final offline = InviteMemberUseCase(
        repo,
        cloudGuard: CloudMutationGuard(isOnline: () => false),
      );
      await expectLater(
        () => offline(identifier: 'a@example.com'),
        throwsA(isA<AddMemberOfflineFailure>()),
      );
    });
  });

  group('AddMemberBloc invite path', () {
    late _MockAddMemberRepo addRepo;
    late _MockMembershipsRepo membershipsRepo;
    late AddMemberBloc bloc;

    setUp(() {
      addRepo = _MockAddMemberRepo();
      membershipsRepo = _MockMembershipsRepo();
      when(
        () => membershipsRepo.listPlans(activeOnly: any(named: 'activeOnly')),
      ).thenAnswer(
        (_) async => const [
          MembershipPlan(
            id: 'p1',
            tenantId: 't1',
            name: 'Monthly',
            durationDays: 30,
            priceCents: 50000,
            currency: 'EGP',
            isActive: true,
          ),
        ],
      );
      bloc = AddMemberBloc(
        findAthlete: FindAthleteForEnrollUseCase(addRepo),
        enrollGymMember: EnrollGymMemberUseCase(addRepo),
        inviteMember: InviteMemberUseCase(
          addRepo,
          cloudGuard: CloudMutationGuard(isOnline: () => true),
        ),
        listPlans: ListMembershipPlansUseCase(membershipsRepo),
        assignMembership: AssignMembershipUseCase(membershipsRepo),
      );
    });

    tearDown(() async {
      await bloc.close();
    });

    test('email invite success with optional plan', () async {
      when(() => addRepo.inviteMember(any())).thenAnswer(
        (_) async => const MemberInviteResult(
          inviteId: 'inv-1',
          email: 'new@example.com',
          tenantId: 't1',
          message: 'Member invite sent',
          planId: 'p1',
        ),
      );

      bloc.add(const AddMemberStarted());
      await pumpEventQueue();
      bloc.add(const AddMemberInvitePlanSelected('p1'));
      bloc.add(
        const AddMemberInviteRequested(
          identifier: 'new@example.com',
          displayName: 'Nova',
        ),
      );
      await pumpEventQueue();

      expect(bloc.state.status, AddMemberStatus.idle);
      expect(bloc.state.messageKey, 'add_member.success.invite_sent');
      expect(bloc.state.invitePlanId, isNull);
      final invite =
          verify(() => addRepo.inviteMember(captureAny())).captured.single
              as MemberInvite;
      expect(invite.email, 'new@example.com');
      expect(invite.displayName, 'Nova');
      expect(invite.planId, 'p1');
    });

    test('username not found maps honest error', () async {
      when(
        () => addRepo.inviteMember(any()),
      ).thenThrow(const AddMemberUsernameNotFoundFailure());

      bloc.add(const AddMemberStarted());
      await pumpEventQueue();
      bloc.add(const AddMemberInviteRequested(identifier: 'missing_user'));
      await pumpEventQueue();

      expect(bloc.state.status, AddMemberStatus.idle);
      expect(bloc.state.messageKey, 'add_member.error.username_not_found');
    });

    test('email send failure maps honest error', () async {
      when(
        () => addRepo.inviteMember(any()),
      ).thenThrow(const AddMemberInviteEmailFailure());

      bloc.add(const AddMemberStarted());
      await pumpEventQueue();
      bloc.add(const AddMemberInviteRequested(identifier: 'a@example.com'));
      await pumpEventQueue();

      expect(bloc.state.messageKey, 'add_member.error.invite_email_failed');
    });
  });

  group('AddMemberScreen Invite tab UI', () {
    late _MockAddMemberRepo addRepo;
    late _MockMembershipsRepo membershipsRepo;
    late AddMemberBloc bloc;

    setUp(() {
      addRepo = _MockAddMemberRepo();
      membershipsRepo = _MockMembershipsRepo();
      when(
        () => membershipsRepo.listPlans(activeOnly: any(named: 'activeOnly')),
      ).thenAnswer((_) async => const []);
      when(() => addRepo.inviteMember(any())).thenAnswer(
        (_) async => const MemberInviteResult(
          inviteId: 'inv-1',
          email: 'a@example.com',
          tenantId: 't1',
          message: 'ok',
        ),
      );
      bloc = AddMemberBloc(
        findAthlete: FindAthleteForEnrollUseCase(addRepo),
        enrollGymMember: EnrollGymMemberUseCase(addRepo),
        inviteMember: InviteMemberUseCase(
          addRepo,
          cloudGuard: CloudMutationGuard(isOnline: () => true),
        ),
        listPlans: ListMembershipPlansUseCase(membershipsRepo),
        assignMembership: AssignMembershipUseCase(membershipsRepo),
      );
    });

    tearDown(() async {
      await bloc.close();
    });

    testWidgets('Invite tab shows live Send invite CTA (not stub)', (
      tester,
    ) async {
      await pumpLocalizedApp(
        tester,
        BlocProvider.value(value: bloc, child: const AddMemberScreen()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Invite'));
      await tester.pumpAndSettle();

      expect(find.text('Send invite'), findsOneWidget);
      expect(find.text('Send invite later'), findsNothing);
      expect(find.textContaining('Visual Spec Card'), findsOneWidget);

      await tester.enterText(
        find.byType(TextFormField).first,
        'athlete@example.com',
      );
      await tester.tap(find.text('Send invite'));
      await tester.pumpAndSettle();

      verify(() => addRepo.inviteMember(any())).called(1);
    });
  });
}
