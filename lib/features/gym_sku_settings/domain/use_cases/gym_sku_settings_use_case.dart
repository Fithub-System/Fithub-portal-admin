import '../entities/gym_sku_settings.dart';
import '../repositories/gym_sku_settings_repository.dart';

class GetGymSkuSettingsUseCase {
  const GetGymSkuSettingsUseCase(this._repository);

  final GymSkuSettingsRepository _repository;

  Future<GymSkuSettings> call() => _repository.getSettings();
}

class SetGymSkuSettingsUseCase {
  const SetGymSkuSettingsUseCase(this._repository);

  final GymSkuSettingsRepository _repository;

  Future<GymSkuSettings> call({
    required SkuMode skuMode,
    required bool marketplaceOptIn,
  }) {
    final effectiveOptIn =
        skuMode.allowsMarketplaceOptIn ? marketplaceOptIn : false;
    return _repository.setSettings(
      skuMode: skuMode,
      marketplaceOptIn: effectiveOptIn,
    );
  }
}
