import 'package:equatable/equatable.dart';

/// Tenant promo code (FEAT-23 `promo_codes`).
class PromoCode extends Equatable {
  const PromoCode({
    required this.id,
    required this.tenantId,
    required this.code,
    required this.currency,
    required this.status,
    required this.redeemedCount,
    this.percentOff,
    this.amountOffCents,
    this.expiresAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String tenantId;
  final String code;
  final int? percentOff;
  final int? amountOffCents;
  final String currency;
  final DateTime? expiresAt;
  final String status;
  final int redeemedCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isLifetime => expiresAt == null;
  bool get isPercent => percentOff != null;

  @override
  List<Object?> get props => [
    id,
    tenantId,
    code,
    percentOff,
    amountOffCents,
    currency,
    expiresAt,
    status,
    redeemedCount,
    createdAt,
    updatedAt,
  ];
}
