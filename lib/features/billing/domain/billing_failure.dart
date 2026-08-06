/// Billing feature failures (i18n keys under `billing.error.*`).
sealed class BillingFailure implements Exception {
  const BillingFailure(this.messageKey);
  final String messageKey;

  @override
  String toString() => messageKey;
}

final class BillingNotConfiguredFailure extends BillingFailure {
  const BillingNotConfiguredFailure() : super('billing.error.not_configured');
}

final class BillingForbiddenFailure extends BillingFailure {
  const BillingForbiddenFailure() : super('billing.error.forbidden');
}

final class BillingValidationFailure extends BillingFailure {
  const BillingValidationFailure([super.messageKey = 'billing.error.invalid']);
}

final class BillingUnknownFailure extends BillingFailure {
  const BillingUnknownFailure() : super('billing.error.unknown');
}
