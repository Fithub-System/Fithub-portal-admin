import '../entities/athlete_enroll_match.dart';
import '../entities/enroll_gym_member_result.dart';
import '../repositories/add_member_repository.dart';

class FindAthleteForEnrollUseCase {
  const FindAthleteForEnrollUseCase(this._repository);
  final AddMemberRepository _repository;

  Future<AthleteEnrollMatch?> call(String email) {
    return _repository.findAthleteForEnroll(email);
  }
}

class EnrollGymMemberUseCase {
  const EnrollGymMemberUseCase(this._repository);
  final AddMemberRepository _repository;

  Future<EnrollGymMemberResult> call(String athleteId) {
    return _repository.enrollGymMember(athleteId);
  }
}
