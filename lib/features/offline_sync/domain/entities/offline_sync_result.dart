/// Outcome of a reconnect sync pass over [LocalAttendanceQueue].
class OfflineSyncResult {
  const OfflineSyncResult({
    required this.upsertedCount,
    this.occupancyPushed = false,
    this.occupancyUpdateDenied = false,
    this.occupancyDenialDetail,
  });

  /// Empty pending queue — no remote work.
  const OfflineSyncResult.empty()
    : upsertedCount = 0,
      occupancyPushed = false,
      occupancyUpdateDenied = false,
      occupancyDenialDetail = null;

  final int upsertedCount;
  final bool occupancyPushed;

  /// Gyms `current_occupancy` UPDATE blocked (RLS / GRANT) — report to Backend.
  final bool occupancyUpdateDenied;
  final String? occupancyDenialDetail;

  bool get hasPendingBackendOccupancyWork => occupancyUpdateDenied;
}
