import '../../domain/entities/gym_sku_settings.dart';
import '../../domain/repositories/gym_sku_settings_repository.dart';
import '../data_sources/remote/gym_sku_settings_remote_data_source.dart';

class GymSkuSettingsRepositoryImpl implements GymSkuSettingsRepository {
  GymSkuSettingsRepositoryImpl({
    required GymSkuSettingsRemoteDataSource remote,
    required Future<String> Function() resolveTenantId,
  }) : _remote = remote,
       _resolveTenantId = resolveTenantId;

  final GymSkuSettingsRemoteDataSource _remote;
  final Future<String> Function() _resolveTenantId;

  @override
  Future<GymSkuSettings> getSettings() async {
    final tenantId = await _resolveTenantId();
    final model = await _remote.fetchSettings(tenantId: tenantId);
    return model.toEntity();
  }

  @override
  Future<GymSkuSettings> setSettings({
    required SkuMode skuMode,
    required bool marketplaceOptIn,
  }) async {
    final model = await _remote.setGymSkuSettings(
      skuMode: skuMode,
      marketplaceOptIn: marketplaceOptIn,
    );
    return model.toEntity();
  }
}
