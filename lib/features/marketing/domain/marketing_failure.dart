/// Marketing failures (i18n keys under `marketing.error.*`).
sealed class MarketingFailure implements Exception {
  const MarketingFailure(this.messageKey);
  final String messageKey;

  @override
  String toString() => messageKey;
}

final class MarketingNotConfiguredFailure extends MarketingFailure {
  const MarketingNotConfiguredFailure()
    : super('marketing.error.not_configured');
}

final class MarketingForbiddenFailure extends MarketingFailure {
  const MarketingForbiddenFailure() : super('marketing.error.forbidden');
}

final class MarketingValidationFailure extends MarketingFailure {
  const MarketingValidationFailure([
    super.messageKey = 'marketing.error.invalid',
  ]);
}

final class MarketingUnknownFailure extends MarketingFailure {
  const MarketingUnknownFailure() : super('marketing.error.unknown');
}

/// FEAT-26 — campaign / promo upserts require live cloud.
final class MarketingOfflineFailure extends MarketingFailure {
  const MarketingOfflineFailure() : super('marketing.error.offline');
}
