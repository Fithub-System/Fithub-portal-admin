import 'package:equatable/equatable.dart';

/// Row from `coach_payout_requests_for_admin` (FEAT-30 §4.2).
enum CoachPayoutRequestStatus {
  pending,
  paid,
  rejected;

  static CoachPayoutRequestStatus fromApi(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'paid':
        return CoachPayoutRequestStatus.paid;
      case 'rejected':
        return CoachPayoutRequestStatus.rejected;
      default:
        return CoachPayoutRequestStatus.pending;
    }
  }

  String get apiValue => name;
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
      ];
}
