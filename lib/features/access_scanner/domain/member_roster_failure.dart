/// Member roster sync failures (FEAT-01 Portal — Backend policy dependency).
sealed class MemberRosterFailure {
  const MemberRosterFailure(this.messageKey);

  final String messageKey;
}

class MemberRosterNotConfiguredFailure extends MemberRosterFailure {
  const MemberRosterNotConfiguredFailure()
    : super('access_scanner.roster.error.not_configured');
}

class MemberRosterPolicyFailure extends MemberRosterFailure {
  const MemberRosterPolicyFailure()
    : super('access_scanner.roster.error.policy');
}

class MemberRosterUnknownFailure extends MemberRosterFailure {
  const MemberRosterUnknownFailure()
    : super('access_scanner.roster.error.unknown');
}
