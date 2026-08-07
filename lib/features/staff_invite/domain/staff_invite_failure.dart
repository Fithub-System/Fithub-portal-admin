/// Domain failures for staff invite (FEAT-05 US-B / US-C).
sealed class StaffInviteFailure implements Exception {
  const StaffInviteFailure(this.message);

  /// i18n key or server-localized message.
  final String message;

  @override
  String toString() => message;
}

final class StaffInviteNotConfiguredFailure extends StaffInviteFailure {
  const StaffInviteNotConfiguredFailure([
    super.message = 'staff_invite.error.not_configured',
  ]);
}

final class StaffInviteForbiddenFailure extends StaffInviteFailure {
  const StaffInviteForbiddenFailure([
    super.message = 'staff_invite.error.forbidden',
  ]);
}

final class StaffInviteValidationFailure extends StaffInviteFailure {
  const StaffInviteValidationFailure([
    super.message = 'staff_invite.error.invalid_body',
  ]);
}

final class StaffInviteServerFailure extends StaffInviteFailure {
  const StaffInviteServerFailure([
    super.message = 'staff_invite.error.unknown',
  ]);
}

/// FEAT-26 — staff invite / password-recovery admin flows require live cloud.
final class StaffInviteOfflineFailure extends StaffInviteFailure {
  const StaffInviteOfflineFailure([
    super.message = 'staff_invite.error.offline',
  ]);
}
