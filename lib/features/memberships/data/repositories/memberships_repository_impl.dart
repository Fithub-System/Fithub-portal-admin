import '../../domain/entities/membership_plan.dart';
import '../../domain/repositories/memberships_repository.dart';
import '../data_sources/remote/memberships_remote_data_source.dart';

class MembershipsRepositoryImpl implements MembershipsRepository {
  MembershipsRepositoryImpl({
    required MembershipsRemoteDataSource remote,
    required String Function() resolveTenantId,
  }) : _remote = remote,
       _resolveTenantId = resolveTenantId;

  final MembershipsRemoteDataSource _remote;
  final String Function() _resolveTenantId;

  @override
  Future<List<MembershipPlan>> listPlans({bool activeOnly = false}) {
    return _remote.listPlans(activeOnly: activeOnly);
  }

  @override
  Future<MembershipPlan> createPlan({
    required String name,
    String? description,
    required int durationDays,
    required int priceCents,
    String currency = 'EGP',
  }) {
    return _remote.createPlan(
      tenantId: _resolveTenantId(),
      name: name,
      description: description,
      durationDays: durationDays,
      priceCents: priceCents,
      currency: currency,
    );
  }

  @override
  Future<void> deactivatePlan(String planId) {
    return _remote.deactivatePlan(planId);
  }

  @override
  Future<String> assignMembership({
    required String planId,
    required String athleteId,
  }) {
    return _remote.assignMembership(
      planId: planId,
      athleteId: athleteId,
    );
  }

  @override
  Future<List<MembershipAthleteOption>> listEnrolledAthletes() {
    return _remote.listEnrolledAthletes();
  }
}
