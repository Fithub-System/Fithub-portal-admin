/// Memberships feature failures (i18n keys under `memberships.error.*`).
sealed class MembershipsFailure implements Exception {
  const MembershipsFailure(this.messageKey);
  final String messageKey;

  @override
  String toString() => messageKey;
}

final class MembershipsNotConfiguredFailure extends MembershipsFailure {
  const MembershipsNotConfiguredFailure()
    : super('memberships.error.not_configured');
}

final class MembershipsForbiddenFailure extends MembershipsFailure {
  const MembershipsForbiddenFailure() : super('memberships.error.forbidden');
}

final class MembershipsValidationFailure extends MembershipsFailure {
  const MembershipsValidationFailure([
    super.messageKey = 'memberships.error.invalid',
  ]);
}

final class MembershipsUnknownFailure extends MembershipsFailure {
  const MembershipsUnknownFailure() : super('memberships.error.unknown');
}
