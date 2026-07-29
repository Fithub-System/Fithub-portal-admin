import 'package:equatable/equatable.dart';

/// Charge status values locked in FEAT-08 §4.2.
enum MembershipChargeStatus {
  pending,
  paid,
  failed,
  waived;

  static MembershipChargeStatus fromApi(String raw) {
    switch (raw.toLowerCase()) {
      case 'paid':
        return MembershipChargeStatus.paid;
      case 'failed':
        return MembershipChargeStatus.failed;
      case 'waived':
        return MembershipChargeStatus.waived;
      case 'pending':
      default:
        return MembershipChargeStatus.pending;
    }
  }

  String get apiValue => name;

  String get labelKey => 'billing.status.$name';
}

/// Tenant membership charge row (`public.membership_charges`).
class MembershipCharge extends Equatable {
  const MembershipCharge({
    required this.id,
    required this.tenantId,
    required this.athleteId,
    required this.athleteMembershipId,
    required this.planId,
    required this.amountCents,
    required this.currency,
    required this.status,
    required this.dueAt,
    this.paidAt,
    this.athleteName,
    this.planName,
  });

  final String id;
  final String tenantId;
  final String athleteId;
  final String athleteMembershipId;
  final String planId;
  final int amountCents;
  final String currency;
  final MembershipChargeStatus status;
  final DateTime dueAt;
  final DateTime? paidAt;
  final String? athleteName;
  final String? planName;

  bool get canMarkPaidOrWaived =>
      status == MembershipChargeStatus.pending ||
      status == MembershipChargeStatus.failed;

  @override
  List<Object?> get props => [
    id,
    tenantId,
    athleteId,
    athleteMembershipId,
    planId,
    amountCents,
    currency,
    status,
    dueAt,
    paidAt,
    athleteName,
    planName,
  ];
}
