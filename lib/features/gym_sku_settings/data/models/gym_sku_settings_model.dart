import '../../domain/entities/gym_sku_settings.dart';

class GymSkuSettingsModel {
  const GymSkuSettingsModel({
    required this.id,
    required this.skuMode,
    required this.marketplaceOptIn,
  });

  final String id;
  final String skuMode;
  final bool marketplaceOptIn;

  factory GymSkuSettingsModel.fromJson(Map<String, dynamic> json) {
    return GymSkuSettingsModel(
      id: json['id'] as String,
      skuMode: json['sku_mode'] as String? ?? 'private_cloud',
      marketplaceOptIn: json['marketplace_opt_in'] as bool? ?? false,
    );
  }

  GymSkuSettings toEntity() {
    return GymSkuSettings(
      id: id,
      skuMode: SkuMode.fromApi(skuMode),
      marketplaceOptIn: marketplaceOptIn,
    );
  }
}
