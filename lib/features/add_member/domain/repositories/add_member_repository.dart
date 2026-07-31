import '../entities/athlete_enroll_match.dart';
import '../entities/enroll_gym_member_result.dart';

/// Port for Admin enroll RPCs (FEAT-13). No raw `gym_members` INSERT.
abstract class AddMemberRepository {
  /// `find_athlete_for_enroll` — null when no match (empty jsonb).
  Future<AthleteEnrollMatch?> findAthleteForEnroll(String email);

  /// `enroll_gym_member` — Admin-only, tenant forced server-side.
  Future<EnrollGymMemberResult> enrollGymMember(String athleteId);
}
