import '../../models/staff_invite_model.dart';
import '../../../domain/entities/staff_invite.dart';

/// Remote boundary for invite staff (Dio / Edge Function).
abstract class StaffInviteRemoteDataSource {
  Future<StaffInviteModel> inviteStaff(StaffInvite invite);
}
