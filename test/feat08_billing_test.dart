import 'package:flutter_test/flutter_test.dart';
import 'package:fithub_portal_admin/features/auth/domain/entities/employee_profile.dart';
import 'package:fithub_portal_admin/features/billing/domain/billing_failure.dart';
import 'package:fithub_portal_admin/features/billing/domain/entities/membership_charge.dart';
import 'package:fithub_portal_admin/features/billing/domain/repositories/billing_repository.dart';
import 'package:fithub_portal_admin/features/billing/domain/use_cases/billing_use_cases.dart';
import 'package:fithub_portal_admin/features/billing/presentation/cubit/billing_cubit.dart';
import 'package:fithub_portal_admin/features/billing/presentation/screens/marketing_promotions_screen.dart';
import 'package:fithub_portal_admin/features/home/presentation/pages/portal_shell_destinations.dart';
import 'package:mocktail/mocktail.dart';

class _MockBillingRepo extends Mock implements BillingRepository {}

void main() {
  late _MockBillingRepo repository;

  setUpAll(() {
    registerFallbackValue(MembershipChargeStatus.paid);
  });

  setUp(() {
    repository = _MockBillingRepo();
  });

  group('FEAT-08 Admin gate', () {
    test('Admin can manage billing; Receptionist cannot', () {
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
      expect(admin.canManageBilling, isTrue);
      expect(receptionist.canManageBilling, isFalse);
    });
  });

  group('MembershipChargeStatus', () {
    test('fromApi maps known values', () {
      expect(
        MembershipChargeStatus.fromApi('paid'),
        MembershipChargeStatus.paid,
      );
      expect(
        MembershipChargeStatus.fromApi('WAIVED'),
        MembershipChargeStatus.waived,
      );
      expect(
        MembershipChargeStatus.fromApi('unknown'),
        MembershipChargeStatus.pending,
      );
    });

    test('canMarkPaidOrWaived only for pending/failed', () {
      final pending = MembershipCharge(
        id: 'c1',
        tenantId: 't1',
        athleteId: 'a1',
        athleteMembershipId: 'm1',
        planId: 'p1',
        amountCents: 1000,
        currency: 'EGP',
        status: MembershipChargeStatus.pending,
        dueAt: DateTime.utc(2026, 7, 1),
      );
      final paid = MembershipCharge(
        id: 'c2',
        tenantId: 't1',
        athleteId: 'a1',
        athleteMembershipId: 'm1',
        planId: 'p1',
        amountCents: 1000,
        currency: 'EGP',
        status: MembershipChargeStatus.paid,
        dueAt: DateTime.utc(2026, 7, 1),
      );
      expect(pending.canMarkPaidOrWaived, isTrue);
      expect(paid.canMarkPaidOrWaived, isFalse);
    });
  });

  group('BillingCubit', () {
    test('load emits ready with charges', () async {
      when(() => repository.listCharges(limit: any(named: 'limit'))).thenAnswer(
        (_) async => [
          MembershipCharge(
            id: 'c1',
            tenantId: 't1',
            athleteId: 'a1',
            athleteMembershipId: 'm1',
            planId: 'p1',
            amountCents: 50000,
            currency: 'EGP',
            status: MembershipChargeStatus.pending,
            dueAt: DateTime.utc(2026, 7, 29),
            athleteName: 'Mostafa',
            planName: 'Monthly',
          ),
        ],
      );

      final cubit = BillingCubit(
        listCharges: ListMembershipChargesUseCase(repository),
        updateStatus: UpdateMembershipChargeStatusUseCase(repository),
        applyFreeze: ApplyBillingFreezeUseCase(repository),
      );

      await cubit.load();
      expect(cubit.state.status, BillingStatus.ready);
      expect(cubit.state.charges, hasLength(1));
      await cubit.close();
    });

    test('markStatus maps forbidden failure to message key', () async {
      when(
        () => repository.updateChargeStatus(
          chargeId: any(named: 'chargeId'),
          status: any(named: 'status'),
        ),
      ).thenThrow(const BillingForbiddenFailure());

      final cubit = BillingCubit(
        listCharges: ListMembershipChargesUseCase(repository),
        updateStatus: UpdateMembershipChargeStatusUseCase(repository),
        applyFreeze: ApplyBillingFreezeUseCase(repository),
      );

      await cubit.markStatus(
        chargeId: 'c1',
        status: MembershipChargeStatus.paid,
      );
      expect(cubit.state.messageKey, 'billing.error.forbidden');
      await cubit.close();
    });

    test('markStatus paid reloads and sets success key', () async {
      when(
        () => repository.updateChargeStatus(
          chargeId: any(named: 'chargeId'),
          status: any(named: 'status'),
        ),
      ).thenAnswer(
        (_) async => MembershipCharge(
          id: 'c1',
          tenantId: 't1',
          athleteId: 'a1',
          athleteMembershipId: 'm1',
          planId: 'p1',
          amountCents: 1000,
          currency: 'EGP',
          status: MembershipChargeStatus.paid,
          dueAt: DateTime.utc(2026, 7, 1),
        ),
      );
      when(() => repository.listCharges(limit: any(named: 'limit'))).thenAnswer(
        (_) async => [
          MembershipCharge(
            id: 'c1',
            tenantId: 't1',
            athleteId: 'a1',
            athleteMembershipId: 'm1',
            planId: 'p1',
            amountCents: 1000,
            currency: 'EGP',
            status: MembershipChargeStatus.paid,
            dueAt: DateTime.utc(2026, 7, 1),
          ),
        ],
      );

      final cubit = BillingCubit(
        listCharges: ListMembershipChargesUseCase(repository),
        updateStatus: UpdateMembershipChargeStatusUseCase(repository),
        applyFreeze: ApplyBillingFreezeUseCase(repository),
      );

      await cubit.markStatus(
        chargeId: 'c1',
        status: MembershipChargeStatus.paid,
      );
      expect(cubit.state.messageKey, 'billing.success.marked_paid');
      expect(cubit.state.charges.first.status, MembershipChargeStatus.paid);
      await cubit.close();
    });

    test('applyFreeze stores paused count', () async {
      when(() => repository.applyBillingFreeze()).thenAnswer((_) async => 2);

      final cubit = BillingCubit(
        listCharges: ListMembershipChargesUseCase(repository),
        updateStatus: UpdateMembershipChargeStatusUseCase(repository),
        applyFreeze: ApplyBillingFreezeUseCase(repository),
      );

      await cubit.applyFreeze();
      expect(cubit.state.freezePausedCount, 2);
      expect(cubit.state.messageKey, 'billing.success.freeze_applied');
      await cubit.close();
    });
  });

  group('Stitch citation', () {
    test('MarketingPromotionsScreen cites Marketing & Promotions id', () {
      expect(
        MarketingPromotionsScreen.stitchScreenId,
        'c3207a6938bf40a7872dde7532020ef9',
      );
      expect(
        MarketingPromotionsScreen.stitchScreenTitle,
        'Marketing & Promotions',
      );
    });
  });

  group('Shell destinations', () {
    test('Marketing is index 3; account is 4', () {
      expect(PortalShellDestinations.marketing, 3);
      expect(PortalShellDestinations.account, 4);
      expect(PortalShellDestinations.destinationCount, 5);
    });
  });
}
