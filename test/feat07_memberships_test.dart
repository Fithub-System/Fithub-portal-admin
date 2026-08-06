import 'package:flutter_test/flutter_test.dart';
import 'package:fithub_portal_admin/features/access_scanner/domain/entities/member_roster_entry.dart';
import 'package:fithub_portal_admin/features/auth/domain/entities/employee_profile.dart';
import 'package:fithub_portal_admin/features/memberships/domain/entities/membership_plan.dart';
import 'package:fithub_portal_admin/features/memberships/domain/memberships_failure.dart';
import 'package:fithub_portal_admin/features/memberships/domain/repositories/memberships_repository.dart';
import 'package:fithub_portal_admin/features/memberships/domain/use_cases/memberships_use_cases.dart';
import 'package:fithub_portal_admin/features/memberships/presentation/cubit/memberships_cubit.dart';
import 'package:fithub_portal_admin/features/members/presentation/screens/member_management_screen.dart';
import 'package:fithub_portal_admin/features/memberships/presentation/screens/memberships_screen.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements MembershipsRepository {}

void main() {
  late _MockRepo repository;

  setUp(() {
    repository = _MockRepo();
  });

  group('FEAT-07 Admin gate', () {
    test('Admin can manage; Receptionist cannot', () {
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
      expect(admin.canManageMemberships, isTrue);
      expect(receptionist.canManageMemberships, isFalse);
    });
  });

  group('MembershipsCubit', () {
    test('load emits ready with plans and athletes', () async {
      when(() => repository.listPlans(activeOnly: any(named: 'activeOnly')))
          .thenAnswer(
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
      when(() => repository.listEnrolledAthletes()).thenAnswer(
        (_) async => const [
          MembershipAthleteOption(id: 'a1', fullName: 'Mostafa'),
        ],
      );

      final cubit = MembershipsCubit(
        listPlans: ListMembershipPlansUseCase(repository),
        createPlan: CreateMembershipPlanUseCase(repository),
        deactivatePlan: DeactivateMembershipPlanUseCase(repository),
        assignMembership: AssignMembershipUseCase(repository),
        listAthletes: ListMembershipAthletesUseCase(repository),
      );

      await cubit.load();
      expect(cubit.state.status, MembershipsStatus.ready);
      expect(cubit.state.plans, hasLength(1));
      expect(cubit.state.athletes, hasLength(1));
      await cubit.close();
    });

    test('assign maps forbidden failure to message key', () async {
      when(
        () => repository.assignMembership(
          planId: any(named: 'planId'),
          athleteId: any(named: 'athleteId'),
        ),
      ).thenThrow(const MembershipsForbiddenFailure());

      final cubit = MembershipsCubit(
        listPlans: ListMembershipPlansUseCase(repository),
        createPlan: CreateMembershipPlanUseCase(repository),
        deactivatePlan: DeactivateMembershipPlanUseCase(repository),
        assignMembership: AssignMembershipUseCase(repository),
        listAthletes: ListMembershipAthletesUseCase(repository),
      );

      await cubit.assign(planId: 'p1', athleteId: 'a1');
      expect(cubit.state.messageKey, 'memberships.error.forbidden');
      await cubit.close();
    });
  });

  group('Stitch companion citation', () {
    test('MemberManagementScreen cites Stitch Member Management id', () {
      expect(
        MemberManagementScreen.stitchScreenId,
        '9b35dd57f15443e99f7e798f6867acb6',
      );
      expect(
        MemberManagementScreen.stitchScreenTitle,
        'Member Management',
      );
    });

    test('Legacy MembershipsScreen retains Admin Overview companion id', () {
      expect(
        MembershipsScreen.stitchCompanionScreenId,
        '216e0407184f4c39bd501ed436c1e88b',
      );
      expect(MembershipsScreen.stitchCompanionTitle, 'Admin Overview');
    });
  });

  group('MemberRosterEntry membership cache', () {
    test('copyWith preserves membership fields', () {
      final base = MemberRosterEntry(
        id: 'a1',
        fullName: 'Ada',
        powerScore: 100,
        cryptoSalt: 'salt',
        createdAt: DateTime.utc(2026, 1, 1),
      );
      final withMembership = base.copyWith(
        membershipStatus: 'active',
        membershipPlanName: 'Monthly',
        membershipEndsAt: DateTime.utc(2026, 8, 1),
      );
      expect(withMembership.membershipStatus, 'active');
      expect(withMembership.membershipPlanName, 'Monthly');
      expect(withMembership.id, 'a1');
    });
  });
}
