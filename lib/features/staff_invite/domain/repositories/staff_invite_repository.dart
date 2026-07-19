import '../entities/staff_invite.dart';

/// Port for Admin invite staff (FEAT-05 §4.2).
abstract class StaffInviteRepository {
  Future<StaffInviteResult> inviteStaff(StaffInvite invite);
}
