part of 'marketing_bloc.dart';

enum MarketingStatus { initial, loading, ready, failure }

class MarketingState extends Equatable {
  const MarketingState({
    this.status = MarketingStatus.initial,
    this.campaigns = const [],
    this.promoCodes = const [],
    this.busy = false,
    this.messageKey,
  });

  final MarketingStatus status;
  final List<MarketingCampaign> campaigns;
  final List<PromoCode> promoCodes;
  final bool busy;
  final String? messageKey;

  MarketingState copyWith({
    MarketingStatus? status,
    List<MarketingCampaign>? campaigns,
    List<PromoCode>? promoCodes,
    bool? busy,
    String? messageKey,
    bool clearMessage = false,
  }) {
    return MarketingState(
      status: status ?? this.status,
      campaigns: campaigns ?? this.campaigns,
      promoCodes: promoCodes ?? this.promoCodes,
      busy: busy ?? this.busy,
      messageKey: clearMessage ? null : (messageKey ?? this.messageKey),
    );
  }

  @override
  List<Object?> get props => [status, campaigns, promoCodes, busy, messageKey];
}
