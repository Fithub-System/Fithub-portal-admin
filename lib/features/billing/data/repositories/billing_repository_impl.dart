import '../../domain/entities/membership_charge.dart';
import '../../domain/repositories/billing_repository.dart';
import '../data_sources/remote/billing_remote_data_source.dart';

class BillingRepositoryImpl implements BillingRepository {
  BillingRepositoryImpl({
    required BillingRemoteDataSource remote,
    required Future<String> Function() resolveTenantId,
  }) : _remote = remote,
       _resolveTenantId = resolveTenantId;

  final BillingRemoteDataSource _remote;
  final Future<String> Function() _resolveTenantId;

  @override
  Future<List<MembershipCharge>> listCharges({int limit = 50}) async {
    final tenantId = await _resolveTenantId();
    return _remote.listCharges(tenantId: tenantId, limit: limit);
  }

  @override
  Future<MembershipCharge> updateChargeStatus({
    required String chargeId,
    required MembershipChargeStatus status,
  }) {
    return _remote.updateChargeStatus(chargeId: chargeId, status: status);
  }

  @override
  Future<int> applyBillingFreeze() async {
    final tenantId = await _resolveTenantId();
    return _remote.applyBillingFreeze(tenantId: tenantId);
  }
}
