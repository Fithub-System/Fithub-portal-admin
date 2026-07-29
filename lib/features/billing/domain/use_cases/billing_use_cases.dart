import '../entities/membership_charge.dart';
import '../repositories/billing_repository.dart';

class ListMembershipChargesUseCase {
  const ListMembershipChargesUseCase(this._repository);
  final BillingRepository _repository;

  Future<List<MembershipCharge>> call({int limit = 50}) {
    return _repository.listCharges(limit: limit);
  }
}

class UpdateMembershipChargeStatusUseCase {
  const UpdateMembershipChargeStatusUseCase(this._repository);
  final BillingRepository _repository;

  Future<MembershipCharge> call({
    required String chargeId,
    required MembershipChargeStatus status,
  }) {
    return _repository.updateChargeStatus(chargeId: chargeId, status: status);
  }
}

class ApplyBillingFreezeUseCase {
  const ApplyBillingFreezeUseCase(this._repository);
  final BillingRepository _repository;

  Future<int> call() => _repository.applyBillingFreeze();
}
