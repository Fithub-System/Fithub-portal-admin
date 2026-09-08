import '../../../../core/network/cloud_mutation_guard.dart';
import '../add_member_failure.dart';
import '../entities/athlete_enroll_match.dart';
import '../entities/enroll_gym_member_result.dart';
import '../entities/member_invite.dart';
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

/// FEAT-62 — Admin Invite tab → Edge `invite-member`.
class InviteMemberUseCase {
  InviteMemberUseCase(
    this._repository, {
    required CloudMutationGuard cloudGuard,
  }) : _cloudGuard = cloudGuard;

  final AddMemberRepository _repository;
  final CloudMutationGuard _cloudGuard;

  Future<MemberInviteResult> call({
    required String identifier,
    String? displayName,
    String? planId,
  }) {
    if (!_cloudGuard.isOnline) {
      throw const AddMemberOfflineFailure();
    }

    final trimmed = identifier.trim();
    if (trimmed.isEmpty) {
      throw const AddMemberValidationFailure(
        'add_member.validation.identifier',
      );
    }

    final looksEmail = trimmed.contains('@');
    if (looksEmail) {
      final email = trimmed.toLowerCase();
      if (!_looksLikeEmail(email)) {
        throw const AddMemberValidationFailure('add_member.validation.email');
      }
      return _repository.inviteMember(
        MemberInvite(
          email: email,
          displayName: _optional(displayName),
          planId: _optional(planId),
        ),
      );
    }

    final username = trimmed.toLowerCase();
    if (username.length < 2) {
      throw const AddMemberValidationFailure(
        'add_member.validation.identifier',
      );
    }
    return _repository.inviteMember(
      MemberInvite(
        username: username,
        displayName: _optional(displayName),
        planId: _optional(planId),
      ),
    );
  }

  bool _looksLikeEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }

  String? _optional(String? value) {
    final t = value?.trim();
    if (t == null || t.isEmpty) return null;
    return t;
  }
}
