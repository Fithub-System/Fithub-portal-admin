/// Thin cloud reads for Overview KPI bind (FEAT-60).
abstract class OverviewMetricsRemoteDataSource {
  /// Count of `attendance_logs` for [tenantId] with `checked_in_at` ≥ [dayStartUtc].
  Future<int> countCheckInsSince({
    required String tenantId,
    required DateTime dayStartUtc,
  });

  /// Paid charges with `paid_at` ≥ [dayStartUtc] — sum cents + currency sample.
  Future<({int totalCents, String currency})> sumPaidChargesSince({
    required String tenantId,
    required DateTime dayStartUtc,
  });
}
