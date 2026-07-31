part of 'gym_sku_settings_bloc.dart';

sealed class GymSkuSettingsEvent extends Equatable {
  const GymSkuSettingsEvent();

  @override
  List<Object?> get props => [];
}

final class GymSkuSettingsLoadRequested extends GymSkuSettingsEvent {
  const GymSkuSettingsLoadRequested();
}

final class GymSkuSettingsSkuModeChanged extends GymSkuSettingsEvent {
  const GymSkuSettingsSkuModeChanged(this.skuMode);

  final SkuMode skuMode;

  @override
  List<Object?> get props => [skuMode];
}

final class GymSkuSettingsMarketplaceChanged extends GymSkuSettingsEvent {
  const GymSkuSettingsMarketplaceChanged(this.optIn);

  final bool optIn;

  @override
  List<Object?> get props => [optIn];
}

final class GymSkuSettingsSaveRequested extends GymSkuSettingsEvent {
  const GymSkuSettingsSaveRequested();
}
