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
