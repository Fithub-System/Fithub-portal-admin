import 'package:equatable/equatable.dart';

/// Gym SKU mode — FEAT-10 / `gyms.sku_mode` CHECK.
enum SkuMode {
  network,
  privateCloud;

  static SkuMode fromApi(String value) {
    switch (value) {
      case 'network':
        return SkuMode.network;
      case 'private_cloud':
        return SkuMode.privateCloud;
      default:
        return SkuMode.privateCloud;
    }
  }

  String get apiValue => switch (this) {
    SkuMode.network => 'network',
    SkuMode.privateCloud => 'private_cloud',
  };

  bool get allowsMarketplaceOptIn => this == SkuMode.network;
}

/// Tenant gym SKU / Marketplace flags (FEAT-10 US-D).
class GymSkuSettings extends Equatable {
  const GymSkuSettings({
    required this.id,
    required this.skuMode,
    required this.marketplaceOptIn,
  });

  final String id;
  final SkuMode skuMode;
  final bool marketplaceOptIn;

  /// Effective opt-in after Private Cloud force-off (AC-B2 / UI mirror).
  bool get effectiveMarketplaceOptIn =>
      skuMode.allowsMarketplaceOptIn && marketplaceOptIn;

  GymSkuSettings copyWith({
    String? id,
    SkuMode? skuMode,
    bool? marketplaceOptIn,
  }) {
    return GymSkuSettings(
      id: id ?? this.id,
      skuMode: skuMode ?? this.skuMode,
      marketplaceOptIn: marketplaceOptIn ?? this.marketplaceOptIn,
    );
  }

  @override
  List<Object?> get props => [id, skuMode, marketplaceOptIn];
}
