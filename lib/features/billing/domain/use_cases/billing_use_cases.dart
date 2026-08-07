import '../../../../core/network/cloud_mutation_guard.dart';
import '../billing_failure.dart';
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
  UpdateMembershipChargeStatusUseCase(
    this._repository, {
    required CloudMutationGuard cloudGuard,
  }) : _cloudGuard = cloudGuard;

  final BillingRepository _repository;
  final CloudMutationGuard _cloudGuard;

  Future<MembershipCharge> call({
    required String chargeId,
    required MembershipChargeStatus status,
  }) {
    if (!_cloudGuard.isOnline) {
      throw const BillingOfflineFailure();
    }
    return _repository.updateChargeStatus(chargeId: chargeId, status: status);
  }
}

class ApplyBillingFreezeUseCase {
  ApplyBillingFreezeUseCase(
    this._repository, {
    required CloudMutationGuard cloudGuard,
  }) : _cloudGuard = cloudGuard;

  final BillingRepository _repository;
  final CloudMutationGuard _cloudGuard;

  Future<int> call() {
    if (!_cloudGuard.isOnline) {
      throw const BillingOfflineFailure();
    }
    return _repository.applyBillingFreeze();
  }
}
