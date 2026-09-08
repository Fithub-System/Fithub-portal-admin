import '../entities/freeze_policy.dart';
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

  Future<String> renewMembership(String membershipId);

  Future<String> freezeMembership({
    required String membershipId,
    int? days,
  });

  Future<String> unfreezeMembership(String membershipId);

  Future<List<FreezePolicy>> listFreezePolicies();

  Future<String> upsertFreezePolicy({
    required int freezeDays,
    required int maxFreezeDaysPerTime,
    String? planId,
  });
}
