import '../entities/coach_payout_request.dart';

/// Port for Admin Payout Queue (FEAT-30) — no Supabase in presentation.
abstract class AdminPayoutQueueRepository {
  Future<List<CoachPayoutRequest>> listRequests({int limit = 100});

  Future<CoachPayoutRequest> fulfill({
    required String requestId,
    required AdminPayoutFulfillAction action,
  });
}
