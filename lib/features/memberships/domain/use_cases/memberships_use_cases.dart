import '../entities/freeze_policy.dart';
import '../entities/membership_plan.dart';
import '../repositories/memberships_repository.dart';

class ListMembershipPlansUseCase {
  const ListMembershipPlansUseCase(this._repository);
  final MembershipsRepository _repository;

  Future<List<MembershipPlan>> call({bool activeOnly = false}) {
    return _repository.listPlans(activeOnly: activeOnly);
  }
}

class CreateMembershipPlanUseCase {
  const CreateMembershipPlanUseCase(this._repository);
  final MembershipsRepository _repository;

  Future<MembershipPlan> call({
    required String name,
    String? description,
    required int durationDays,
    required int priceCents,
    String currency = 'EGP',
  }) {
    return _repository.createPlan(
      name: name,
      description: description,
      durationDays: durationDays,
      priceCents: priceCents,
      currency: currency,
    );
  }
}

class DeactivateMembershipPlanUseCase {
  const DeactivateMembershipPlanUseCase(this._repository);
  final MembershipsRepository _repository;

  Future<void> call(String planId) => _repository.deactivatePlan(planId);
}

class AssignMembershipUseCase {
  const AssignMembershipUseCase(this._repository);
  final MembershipsRepository _repository;

  Future<String> call({
    required String planId,
    required String athleteId,
  }) {
    return _repository.assignMembership(
      planId: planId,
      athleteId: athleteId,
    );
  }
}

class ListMembershipAthletesUseCase {
  const ListMembershipAthletesUseCase(this._repository);
  final MembershipsRepository _repository;

  Future<List<MembershipAthleteOption>> call() {
    return _repository.listEnrolledAthletes();
  }
}

class RenewMembershipUseCase {
  const RenewMembershipUseCase(this._repository);
  final MembershipsRepository _repository;

  Future<String> call(String membershipId) {
    return _repository.renewMembership(membershipId);
  }
}

class FreezeMembershipUseCase {
  const FreezeMembershipUseCase(this._repository);
  final MembershipsRepository _repository;

  Future<String> call({required String membershipId, int? days}) {
    return _repository.freezeMembership(
      membershipId: membershipId,
      days: days,
    );
  }
}

class UnfreezeMembershipUseCase {
  const UnfreezeMembershipUseCase(this._repository);
  final MembershipsRepository _repository;

  Future<String> call(String membershipId) {
    return _repository.unfreezeMembership(membershipId);
  }
}

class ListFreezePoliciesUseCase {
  const ListFreezePoliciesUseCase(this._repository);
  final MembershipsRepository _repository;

  Future<List<FreezePolicy>> call() => _repository.listFreezePolicies();
}

class UpsertFreezePolicyUseCase {
  const UpsertFreezePolicyUseCase(this._repository);
  final MembershipsRepository _repository;

  Future<String> call({
    required int freezeDays,
    required int maxFreezeDaysPerTime,
    String? planId,
  }) {
    if (maxFreezeDaysPerTime < 1) {
      throw ArgumentError('maxFreezeDaysPerTime must be >= 1');
    }
    if (freezeDays < 0 || freezeDays > maxFreezeDaysPerTime) {
      throw ArgumentError('freezeDays must be 0..maxFreezeDaysPerTime');
    }
    return _repository.upsertFreezePolicy(
      freezeDays: freezeDays,
      maxFreezeDaysPerTime: maxFreezeDaysPerTime,
      planId: planId,
    );
  }
}
