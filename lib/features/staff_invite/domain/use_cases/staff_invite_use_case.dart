import '../../../../core/network/cloud_mutation_guard.dart';
import '../entities/staff_invite.dart';
import '../repositories/staff_invite_repository.dart';
import '../staff_invite_failure.dart';

/// Invites staff via trusted Backend path (user JWT only).
class InviteStaffUseCase {
  InviteStaffUseCase(
    this._repository, {
    required CloudMutationGuard cloudGuard,
  }) : _cloudGuard = cloudGuard;

  final StaffInviteRepository _repository;
  final CloudMutationGuard _cloudGuard;

  Future<StaffInviteResult> call(StaffInvite invite) {
    if (!_cloudGuard.isOnline) {
      throw const StaffInviteOfflineFailure();
    }
    final email = invite.email.trim().toLowerCase();
    final name = invite.name.trim();
    if (email.isEmpty || name.isEmpty) {
      throw const StaffInviteValidationFailure();
    }
    if (!_looksLikeEmail(email)) {
      throw const StaffInviteValidationFailure('validation.email_invalid');
    }
    return _repository.inviteStaff(
      StaffInvite(email: email, role: invite.role, name: name),
    );
  }

  bool _looksLikeEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }
}
