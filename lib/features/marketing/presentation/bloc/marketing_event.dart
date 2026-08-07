part of 'marketing_bloc.dart';

sealed class MarketingEvent extends Equatable {
  const MarketingEvent();

  @override
  List<Object?> get props => const [];
}

final class MarketingLoadRequested extends MarketingEvent {
  const MarketingLoadRequested();
}

final class MarketingDeployCampaignRequested extends MarketingEvent {
  const MarketingDeployCampaignRequested({
    required this.name,
    required this.startsAt,
    required this.endsAt,
    required this.pushEnabled,
  });

  final String name;
  final DateTime startsAt;
  final DateTime endsAt;
  final bool pushEnabled;

  @override
  List<Object?> get props => [name, startsAt, endsAt, pushEnabled];
}

final class MarketingSoftEndCampaignRequested extends MarketingEvent {
  const MarketingSoftEndCampaignRequested({
    required this.campaign,
    this.status = 'ended',
  });

  final MarketingCampaign campaign;
  final String status;

  @override
  List<Object?> get props => [campaign, status];
}

final class MarketingCreatePromoRequested extends MarketingEvent {
  const MarketingCreatePromoRequested({
    required this.code,
    this.percentOff,
    this.amountOffCents,
    this.currency = 'EGP',
    this.expiresAt,
  });

  final String code;
  final int? percentOff;
  final int? amountOffCents;
  final String currency;
  final DateTime? expiresAt;

  @override
  List<Object?> get props => [
    code,
    percentOff,
    amountOffCents,
    currency,
    expiresAt,
  ];
}

final class MarketingMessageCleared extends MarketingEvent {
  const MarketingMessageCleared();
}
