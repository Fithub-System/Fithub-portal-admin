/// Add Member feature failures (i18n keys under `add_member.error.*`).
sealed class AddMemberFailure implements Exception {
  const AddMemberFailure(this.messageKey);
  final String messageKey;

  @override
  String toString() => messageKey;
}

final class AddMemberNotConfiguredFailure extends AddMemberFailure {
  const AddMemberNotConfiguredFailure()
    : super('add_member.error.not_configured');
}

final class AddMemberForbiddenFailure extends AddMemberFailure {
  const AddMemberForbiddenFailure() : super('add_member.error.forbidden');
}

final class AddMemberNotFoundFailure extends AddMemberFailure {
  const AddMemberNotFoundFailure() : super('add_member.error.not_found');
}

final class AddMemberValidationFailure extends AddMemberFailure {
  const AddMemberValidationFailure([
    super.messageKey = 'add_member.error.invalid',
  ]);
}

final class AddMemberUnknownFailure extends AddMemberFailure {
  const AddMemberUnknownFailure() : super('add_member.error.unknown');
}

/// Username path: no Auth + athletes match (Edge 404).
final class AddMemberUsernameNotFoundFailure extends AddMemberFailure {
  const AddMemberUsernameNotFoundFailure()
    : super('add_member.error.username_not_found');
}

/// Invite created server-side but OTP email could not be sent (Edge 502).
final class AddMemberInviteEmailFailure extends AddMemberFailure {
  const AddMemberInviteEmailFailure()
    : super('add_member.error.invite_email_failed');
}

/// FEAT-26 — invite requires live cloud (same as staff invite).
final class AddMemberOfflineFailure extends AddMemberFailure {
  const AddMemberOfflineFailure() : super('add_member.error.offline');
}

/// Edge/server detail when no dedicated i18n key fits.
final class AddMemberInviteServerFailure extends AddMemberFailure {
  const AddMemberInviteServerFailure([
    super.messageKey = 'add_member.error.invite_failed',
  ]);
}
