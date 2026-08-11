/// Admin payout queue failures (i18n keys under `payouts.error.*`).
sealed class AdminPayoutFailure implements Exception {
  const AdminPayoutFailure(this.messageKey);
  final String messageKey;

  @override
  String toString() => messageKey;
}

final class AdminPayoutNotConfiguredFailure extends AdminPayoutFailure {
  const AdminPayoutNotConfiguredFailure()
      : super('payouts.error.not_configured');
}

final class AdminPayoutForbiddenFailure extends AdminPayoutFailure {
  const AdminPayoutForbiddenFailure() : super('payouts.error.forbidden');
}

final class AdminPayoutNotFoundFailure extends AdminPayoutFailure {
  const AdminPayoutNotFoundFailure() : super('payouts.error.not_found');
}

final class AdminPayoutInvalidStateFailure extends AdminPayoutFailure {
  const AdminPayoutInvalidStateFailure() : super('payouts.error.invalid_state');
}

final class AdminPayoutInvalidInputFailure extends AdminPayoutFailure {
  const AdminPayoutInvalidInputFailure() : super('payouts.error.invalid_input');
}

final class AdminPayoutUnknownFailure extends AdminPayoutFailure {
  const AdminPayoutUnknownFailure() : super('payouts.error.unknown');
}

/// FEAT-26 — fulfill requires live cloud.
final class AdminPayoutOfflineFailure extends AdminPayoutFailure {
  const AdminPayoutOfflineFailure() : super('payouts.error.offline');
}
