import '../entities/coach_payout_request.dart';

/// Port for Admin Payout Queue (FEAT-30/87).
abstract class AdminPayoutQueueRepository {
  Future<List<CoachPayoutRequest>> listRequests({int limit = 100});

  Future<CoachPayoutRequest> fulfill({
    required String requestId,
    required AdminPayoutFulfillAction action,
  });

  Future<CoachPayoutRequest> approve({required String requestId});

  Future<CoachPayoutRequest> beginSettlement({required String requestId});

  Future<CoachPayoutRequest> applySettlement({
    required String requestId,
    required String settlementTxnId,
    required bool success,
    String? note,
  });
}
