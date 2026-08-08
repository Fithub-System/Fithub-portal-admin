import 'package:equatable/equatable.dart';

/// Tenant marketing campaign (FEAT-23 `marketing_campaigns`).
class MarketingCampaign extends Equatable {
  const MarketingCampaign({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.startsAt,
    required this.endsAt,
    required this.pushEnabled,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String tenantId;
  final String name;
  final DateTime startsAt;
  final DateTime endsAt;
  final bool pushEnabled;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isSoftEnded => status == 'ended' || status == 'cancelled';

  @override
  List<Object?> get props => [
    id,
    tenantId,
    name,
    startsAt,
    endsAt,
    pushEnabled,
    status,
    createdAt,
    updatedAt,
  ];
}
