import '../../domain/entities/staff_invite.dart';
import '../../domain/repositories/staff_invite_repository.dart';
import '../data_sources/remote/staff_invite_remote_data_source.dart';

class StaffInviteRepositoryImpl implements StaffInviteRepository {
  StaffInviteRepositoryImpl({required StaffInviteRemoteDataSource remote})
    : _remote = remote;

  final StaffInviteRemoteDataSource _remote;

  @override
  Future<StaffInviteResult> inviteStaff(StaffInvite invite) async {
    final model = await _remote.inviteStaff(invite);
    return model.toEntity();
  }
}
