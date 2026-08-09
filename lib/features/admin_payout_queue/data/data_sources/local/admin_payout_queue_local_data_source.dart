/// Retained empty local DS slot from `cleanarch admin_payout_queue -b`.
///
/// FEAT-30 uses remote Supabase adapters only (no Drift cache for payout queue).
abstract class AdminPayoutQueueLocalDataSource {}
