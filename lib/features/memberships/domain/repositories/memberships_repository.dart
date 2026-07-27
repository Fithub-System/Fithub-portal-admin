import '../entities/membership_plan.dart';

abstract class MembershipsRepository {
  Future<List<MembershipPlan>> listPlans({bool activeOnly = false});

  Future<MembershipPlan> createPlan({
    required String name,
    String? description,
    required int durationDays,
    required int priceCents,
    String currency = 'EGP',
  });

  Future<void> deactivatePlan(String planId);

  Future<String> assignMembership({
    required String planId,
    required String athleteId,
  });

  Future<List<MembershipAthleteOption>> listEnrolledAthletes();
}
