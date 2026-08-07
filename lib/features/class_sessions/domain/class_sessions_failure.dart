/// Class sessions failures (i18n keys under `classes.error.*`).
sealed class ClassSessionsFailure implements Exception {
  const ClassSessionsFailure(this.messageKey);
  final String messageKey;

  @override
  String toString() => messageKey;
}

final class ClassSessionsNotConfiguredFailure extends ClassSessionsFailure {
  const ClassSessionsNotConfiguredFailure()
    : super('classes.error.not_configured');
}

final class ClassSessionsForbiddenFailure extends ClassSessionsFailure {
  const ClassSessionsForbiddenFailure() : super('classes.error.forbidden');
}

final class ClassSessionsValidationFailure extends ClassSessionsFailure {
  const ClassSessionsValidationFailure([
    super.messageKey = 'classes.error.invalid',
  ]);
}

final class ClassSessionsUnknownFailure extends ClassSessionsFailure {
  const ClassSessionsUnknownFailure() : super('classes.error.unknown');
}

/// FEAT-26 — class upsert / cancel require live cloud.
final class ClassSessionsOfflineFailure extends ClassSessionsFailure {
  const ClassSessionsOfflineFailure() : super('classes.error.offline');
}
