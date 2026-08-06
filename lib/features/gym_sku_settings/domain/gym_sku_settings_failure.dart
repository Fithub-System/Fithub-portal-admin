/// Gym SKU settings failures (i18n keys under `gym_settings.error.*`).
sealed class GymSkuSettingsFailure implements Exception {
  const GymSkuSettingsFailure(this.messageKey);
  final String messageKey;

  @override
  String toString() => messageKey;
}

final class GymSkuSettingsNotConfiguredFailure extends GymSkuSettingsFailure {
  const GymSkuSettingsNotConfiguredFailure()
    : super('gym_settings.error.not_configured');
}

final class GymSkuSettingsForbiddenFailure extends GymSkuSettingsFailure {
  const GymSkuSettingsForbiddenFailure()
    : super('gym_settings.error.forbidden');
}

final class GymSkuSettingsValidationFailure extends GymSkuSettingsFailure {
  const GymSkuSettingsValidationFailure([
    super.messageKey = 'gym_settings.error.invalid',
  ]);
}

final class GymSkuSettingsUnknownFailure extends GymSkuSettingsFailure {
  const GymSkuSettingsUnknownFailure() : super('gym_settings.error.unknown');
}
