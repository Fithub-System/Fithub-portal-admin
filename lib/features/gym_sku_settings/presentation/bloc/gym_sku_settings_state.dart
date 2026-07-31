part of 'gym_sku_settings_bloc.dart';

enum GymSkuSettingsStatus { initial, loading, ready, failure }

class GymSkuSettingsState extends Equatable {
  const GymSkuSettingsState({
    this.status = GymSkuSettingsStatus.initial,
    this.saved,
    this.draftSkuMode = SkuMode.privateCloud,
    this.draftMarketplaceOptIn = false,
    this.busy = false,
    this.messageKey,
  });

  final GymSkuSettingsStatus status;
  final GymSkuSettings? saved;
  final SkuMode draftSkuMode;
  final bool draftMarketplaceOptIn;
  final bool busy;
  final String? messageKey;

  bool get isDirty {
    final current = saved;
    if (current == null) return false;
    return draftSkuMode != current.skuMode ||
        draftMarketplaceOptIn != current.effectiveMarketplaceOptIn;
  }

  bool get marketplaceToggleEnabled => draftSkuMode.allowsMarketplaceOptIn;

  GymSkuSettingsState copyWith({
    GymSkuSettingsStatus? status,
    GymSkuSettings? saved,
    SkuMode? draftSkuMode,
    bool? draftMarketplaceOptIn,
    bool? busy,
    String? messageKey,
    bool clearMessage = false,
  }) {
    return GymSkuSettingsState(
      status: status ?? this.status,
      saved: saved ?? this.saved,
      draftSkuMode: draftSkuMode ?? this.draftSkuMode,
      draftMarketplaceOptIn:
          draftMarketplaceOptIn ?? this.draftMarketplaceOptIn,
      busy: busy ?? this.busy,
      messageKey: clearMessage ? null : (messageKey ?? this.messageKey),
    );
  }

  @override
  List<Object?> get props => [
    status,
    saved,
    draftSkuMode,
    draftMarketplaceOptIn,
    busy,
    messageKey,
  ];
}
