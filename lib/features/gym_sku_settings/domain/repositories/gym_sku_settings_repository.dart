import '../entities/gym_sku_settings.dart';

/// Port for gym SKU / Marketplace settings (FEAT-10).
abstract class GymSkuSettingsRepository {
  /// SELECT own tenant gym SKU columns (employee RLS).
  Future<GymSkuSettings> getSettings();

  /// Admin-only RPC `set_gym_sku_settings` — never PostgREST UPDATE.
  Future<GymSkuSettings> setSettings({
    required SkuMode skuMode,
    required bool marketplaceOptIn,
  });
}
