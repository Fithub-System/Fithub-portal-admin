import '../../domain/entities/athlete_enroll_match.dart';
import '../../domain/entities/enroll_gym_member_result.dart';
import '../../domain/entities/member_invite.dart';
import '../../domain/repositories/add_member_repository.dart';
import '../data_sources/remote/add_member_remote_data_source.dart';
import '../data_sources/remote/member_invite_remote_data_source.dart';

class AddMemberRepositoryImpl implements AddMemberRepository {
  AddMemberRepositoryImpl({
    required AddMemberRemoteDataSource remote,
    required MemberInviteRemoteDataSource inviteRemote,
  }) : _remote = remote,
       _inviteRemote = inviteRemote;

  final AddMemberRemoteDataSource _remote;
  final MemberInviteRemoteDataSource _inviteRemote;

  @override
  Future<AthleteEnrollMatch?> findAthleteForEnroll(String email) {
    return _remote.findAthleteForEnroll(email);
  }

  @override
  Future<EnrollGymMemberResult> enrollGymMember(String athleteId) {
    return _remote.enrollGymMember(athleteId);
  }

  @override
  Future<MemberInviteResult> inviteMember(MemberInvite invite) async {
    final model = await _inviteRemote.inviteMember(invite);
    return model.toEntity();
  }
}
