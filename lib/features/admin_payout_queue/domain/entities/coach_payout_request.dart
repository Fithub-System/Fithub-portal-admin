import 'package:equatable/equatable.dart';

/// Row from `coach_payout_requests_for_admin` (FEAT-30/87).
enum CoachPayoutRequestStatus {
  pending,
  approved,
  settling,
  settled,
  failed,
  rejected,
  /// Legacy FEAT-30 terminal (= settled).
  paid;

  static CoachPayoutRequestStatus fromApi(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'approved':
        return CoachPayoutRequestStatus.approved;
      case 'settling':
        return CoachPayoutRequestStatus.settling;
      case 'settled':
        return CoachPayoutRequestStatus.settled;
      case 'failed':
        return CoachPayoutRequestStatus.failed;
      case 'paid':
        return CoachPayoutRequestStatus.paid;
      case 'rejected':
        return CoachPayoutRequestStatus.rejected;
      default:
        return CoachPayoutRequestStatus.pending;
    }
  }

  String get apiValue => name;

  bool get isTerminal =>
      this == settled || this == paid || this == rejected || this == failed;

  bool get isOpen =>
      this == pending || this == approved || this == settling;
}

enum AdminPayoutFulfillAction {
  paid,
  rejected;

  String get apiValue => name;
}

class CoachPayoutRequest extends Equatable {
  const CoachPayoutRequest({
    required this.id,
    required this.tenantId,
    required this.coachEmployeeId,
    required this.coachDisplayName,
    required this.amountCents,
    required this.currency,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.settlementTxnId,
  });

  final String id;
  final String tenantId;
  final String coachEmployeeId;
  final String coachDisplayName;
  final int amountCents;
  final String currency;
  final CoachPayoutRequestStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? settlementTxnId;

  bool get isPending => status == CoachPayoutRequestStatus.pending;

  @override
  List<Object?> get props => [
        id,
        tenantId,
        coachEmployeeId,
        coachDisplayName,
        amountCents,
        currency,
        status,
        createdAt,
        updatedAt,
        settlementTxnId,
      ];
}
