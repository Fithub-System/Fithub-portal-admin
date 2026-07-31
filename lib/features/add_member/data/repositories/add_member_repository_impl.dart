import '../../domain/entities/athlete_enroll_match.dart';
import '../../domain/entities/enroll_gym_member_result.dart';
import '../../domain/repositories/add_member_repository.dart';
import '../data_sources/remote/add_member_remote_data_source.dart';

class AddMemberRepositoryImpl implements AddMemberRepository {
  AddMemberRepositoryImpl({required AddMemberRemoteDataSource remote})
    : _remote = remote;

  final AddMemberRemoteDataSource _remote;

  @override
  Future<AthleteEnrollMatch?> findAthleteForEnroll(String email) {
    return _remote.findAthleteForEnroll(email);
  }

  @override
  Future<EnrollGymMemberResult> enrollGymMember(String athleteId) {
    return _remote.enrollGymMember(athleteId);
  }
}
