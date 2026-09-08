import '../entities/athlete_enroll_match.dart';
import '../entities/enroll_gym_member_result.dart';
import '../entities/member_invite.dart';

/// Port for Admin enroll RPCs (FEAT-13) + member invite Edge (FEAT-62).
///
/// No raw `gym_members` INSERT. No client `service_role`.
abstract class AddMemberRepository {
  /// `find_athlete_for_enroll` — null when no match (empty jsonb).
  Future<AthleteEnrollMatch?> findAthleteForEnroll(String email);

  /// `enroll_gym_member` — Admin-only, tenant forced server-side.
  Future<EnrollGymMemberResult> enrollGymMember(String athleteId);

  /// Edge `invite-member` — Admin JWT; body `{ email|username, … }`.
  Future<MemberInviteResult> inviteMember(MemberInvite invite);
}
