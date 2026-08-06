import '../entities/membership_charge.dart';

abstract class BillingRepository {
  Future<List<MembershipCharge>> listCharges({int limit = 50});

  Future<MembershipCharge> updateChargeStatus({
    required String chargeId,
    required MembershipChargeStatus status,
  });

  /// Admin RPC — pauses overdue pending memberships. Returns count paused.
  Future<int> applyBillingFreeze();
}
