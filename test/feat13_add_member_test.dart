import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fithub_portal_admin/config/theme/kinetic_tokens.dart';
import 'package:fithub_portal_admin/features/access_scanner/domain/entities/member_roster_entry.dart';
import 'package:fithub_portal_admin/features/add_member/domain/add_member_failure.dart';
import 'package:fithub_portal_admin/features/add_member/domain/entities/athlete_enroll_match.dart';
import 'package:fithub_portal_admin/features/add_member/domain/entities/enroll_gym_member_result.dart';
import 'package:fithub_portal_admin/features/add_member/domain/repositories/add_member_repository.dart';
import 'package:fithub_portal_admin/features/add_member/domain/use_cases/add_member_use_cases.dart';
import 'package:fithub_portal_admin/features/add_member/presentation/bloc/add_member_bloc.dart';
import 'package:fithub_portal_admin/features/add_member/presentation/screens/add_member_screen.dart';
import 'package:fithub_portal_admin/features/auth/domain/entities/employee_profile.dart';
import 'package:fithub_portal_admin/features/members/presentation/cubit/member_roster_cubit.dart';
import 'package:fithub_portal_admin/features/members/presentation/screens/member_management_screen.dart';
import 'package:fithub_portal_admin/features/memberships/domain/entities/membership_plan.dart';
import 'package:fithub_portal_admin/features/memberships/domain/repositories/memberships_repository.dart';
import 'package:fithub_portal_admin/features/memberships/domain/use_cases/memberships_use_cases.dart';
import 'package:fithub_portal_admin/features/memberships/presentation/cubit/memberships_cubit.dart';
import 'package:mocktail/mocktail.dart';

import 'support/localized_pump.dart';

class _MockAddMemberRepo extends Mock implements AddMemberRepository {}

class _MockMembershipsRepo extends Mock implements MembershipsRepository {}

class _MockMembershipsCubit extends Mock implements MembershipsCubit {}

class _MockMemberRosterCubit extends Mock implements MemberRosterCubit {}

void main() {
  group('FEAT-13 Admin gate', () {
    test('Admin can enroll; Receptionist cannot', () {
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
  });

  group('Stitch G4 citations', () {
    test('AddMemberScreen cites EN+AR Stitch ids', () {
      expect(
        AddMemberScreen.stitchScreenIdEn,
        'cd59a129a24449478a5249ccb41635fb',
      );
      expect(
        AddMemberScreen.stitchScreenIdAr,
        '89fe5d7afb8d4d4384d7e6498bcdd065',
      );
      expect(
        KineticTokens.stitchAddMemberScreenIdEn,
        AddMemberScreen.stitchScreenIdEn,
      );
      expect(
        KineticTokens.stitchAddMemberScreenIdAr,
        AddMemberScreen.stitchScreenIdAr,
      );
    });
  });

  group('AddMemberBloc', () {
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
        listPlans: ListMembershipPlansUseCase(membershipsRepo),
        assignMembership: AssignMembershipUseCase(membershipsRepo),
      );
    });

    tearDown(() async {
      await bloc.close();
    });

    test('find then enroll with optional assign', () async {
      when(() => addRepo.findAthleteForEnroll('a@example.com')).thenAnswer(
        (_) async => const AthleteEnrollMatch(id: 'a1', fullName: 'Ada'),
      );
      when(() => addRepo.enrollGymMember('a1')).thenAnswer(
        (_) async => const EnrollGymMemberResult(
          tenantId: 't1',
          athleteId: 'a1',
          created: true,
        ),
      );
      when(
        () => membershipsRepo.assignMembership(
          planId: 'p1',
          athleteId: 'a1',
        ),
      ).thenAnswer((_) async => 'm1');

      bloc.add(const AddMemberStarted());
      await pumpEventQueue();
      expect(bloc.state.status, AddMemberStatus.idle);
      expect(bloc.state.plans, hasLength(1));

      bloc.add(const AddMemberFindRequested('a@example.com'));
      await pumpEventQueue();
      expect(bloc.state.status, AddMemberStatus.found);
      expect(bloc.state.match?.id, 'a1');

      bloc.add(const AddMemberPlanSelected('p1'));
      bloc.add(const AddMemberEnrollRequested());
      await pumpEventQueue();
      expect(bloc.state.status, AddMemberStatus.success);
      expect(bloc.state.messageKey, 'add_member.success.enrolled');
      verify(() => addRepo.enrollGymMember('a1')).called(1);
      verify(
        () => membershipsRepo.assignMembership(
          planId: 'p1',
          athleteId: 'a1',
        ),
      ).called(1);
    });

    test('unknown athlete maps to not_found', () async {
      when(
        () => addRepo.findAthleteForEnroll('missing@example.com'),
      ).thenAnswer((_) async => null);

      bloc.add(const AddMemberStarted());
      await pumpEventQueue();
      bloc.add(const AddMemberFindRequested('missing@example.com'));
      await pumpEventQueue();
      expect(bloc.state.status, AddMemberStatus.idle);
      expect(bloc.state.messageKey, 'add_member.error.not_found');
    });

    test('forbidden enroll maps to forbidden key', () async {
      when(() => addRepo.findAthleteForEnroll('a@example.com')).thenAnswer(
        (_) async => const AthleteEnrollMatch(id: 'a1', fullName: 'Ada'),
      );
      when(
        () => addRepo.enrollGymMember('a1'),
      ).thenThrow(const AddMemberForbiddenFailure());

      bloc.add(const AddMemberStarted());
      await pumpEventQueue();
      bloc.add(const AddMemberFindRequested('a@example.com'));
      await pumpEventQueue();
      bloc.add(const AddMemberEnrollRequested());
      await pumpEventQueue();
      expect(bloc.state.status, AddMemberStatus.found);
      expect(bloc.state.messageKey, 'add_member.error.forbidden');
    });
  });

  group('MemberManagementScreen Add CTA', () {
    late _MockMembershipsCubit membershipsCubit;
    late _MockMemberRosterCubit rosterCubit;

    setUp(() {
      membershipsCubit = _MockMembershipsCubit();
      rosterCubit = _MockMemberRosterCubit();

      when(() => membershipsCubit.state).thenReturn(
        const MembershipsState(status: MembershipsStatus.ready, plans: []),
      );
      when(() => membershipsCubit.stream).thenAnswer(
        (_) => Stream.value(
          const MembershipsState(status: MembershipsStatus.ready, plans: []),
        ),
      );
      when(() => membershipsCubit.load()).thenAnswer((_) async {});

      when(() => rosterCubit.state).thenReturn(
        MemberRosterState(
          status: MemberRosterStatus.ready,
          members: [
            MemberRosterEntry(
              id: 'a1',
              fullName: 'Ada',
              powerScore: 100,
              cryptoSalt: 'salt',
              createdAt: DateTime.utc(2026, 1, 1),
            ),
          ],
        ),
      );
      when(() => rosterCubit.stream).thenAnswer(
        (_) => Stream.value(
          MemberRosterState(
            status: MemberRosterStatus.ready,
            members: [
              MemberRosterEntry(
                id: 'a1',
                fullName: 'Ada',
                powerScore: 100,
                cryptoSalt: 'salt',
                createdAt: DateTime.utc(2026, 1, 1),
              ),
            ],
          ),
        ),
      );
      when(() => rosterCubit.load()).thenAnswer((_) async {});
    });

    testWidgets('Admin sees Add New Member CTA', (tester) async {
      await pumpLocalizedApp(
        tester,
        MultiBlocProvider(
          providers: [
            BlocProvider<MembershipsCubit>.value(value: membershipsCubit),
            BlocProvider<MemberRosterCubit>.value(value: rosterCubit),
          ],
          child: const MemberManagementScreen(
            canWrite: true,
            canEnroll: true,
          ),
        ),
      );
      expect(find.text('Add New Member'), findsOneWidget);
    });

    testWidgets('Receptionist does not see Add New Member CTA', (tester) async {
      await pumpLocalizedApp(
        tester,
        MultiBlocProvider(
          providers: [
            BlocProvider<MembershipsCubit>.value(value: membershipsCubit),
            BlocProvider<MemberRosterCubit>.value(value: rosterCubit),
          ],
          child: const MemberManagementScreen(
            canWrite: false,
            canEnroll: false,
          ),
        ),
      );
      expect(find.text('Add New Member'), findsNothing);
    });
  });
}
