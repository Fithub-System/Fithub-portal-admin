import '../../domain/entities/coach_payout_request.dart';

/// Stitch sample rows when Supabase is unbound (visual chrome only).
///
/// Marked `fixture` in Visual Spec Card — live data replaces when Backend binds.
abstract final class AdminPayoutStitchFixtures {
  static final List<CoachPayoutRequest> sampleRequests = [
    CoachPayoutRequest(
      id: 'fixture-pending-1',
      tenantId: 'fixture-tenant',
      coachEmployeeId: 'coach-1',
      coachDisplayName: 'Maya Okonkwo',
      amountCents: 125000,
      currency: 'EGP',
      status: CoachPayoutRequestStatus.pending,
      createdAt: DateTime.utc(2026, 8, 9, 14, 22),
    ),
    CoachPayoutRequest(
      id: 'fixture-pending-2',
      tenantId: 'fixture-tenant',
      coachEmployeeId: 'coach-2',
      coachDisplayName: 'Karim Hassan',
      amountCents: 80000,
      currency: 'EGP',
      status: CoachPayoutRequestStatus.pending,
      createdAt: DateTime.utc(2026, 8, 9, 11, 5),
    ),
    CoachPayoutRequest(
      id: 'fixture-paid-1',
      tenantId: 'fixture-tenant',
      coachEmployeeId: 'coach-3',
      coachDisplayName: 'Lina Farouk',
      amountCents: 210000,
      currency: 'EGP',
      status: CoachPayoutRequestStatus.paid,
      createdAt: DateTime.utc(2026, 8, 9, 8, 0),
      updatedAt: DateTime.now().toUtc(),
    ),
    CoachPayoutRequest(
      id: 'fixture-rejected-1',
      tenantId: 'fixture-tenant',
      coachEmployeeId: 'coach-4',
      coachDisplayName: 'Omar Said',
      amountCents: 45000,
      currency: 'EGP',
      status: CoachPayoutRequestStatus.rejected,
      createdAt: DateTime.utc(2026, 8, 8, 16, 40),
      updatedAt: DateTime.now().toUtc(),
    ),
  ];
}
