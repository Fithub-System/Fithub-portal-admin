/// Domain failures for offline attendance sync (Phase 1.3).
sealed class OfflineSyncFailure implements Exception {
  const OfflineSyncFailure(this.message);

  /// i18n key or diagnostic detail for Backend handoff.
  final String message;

  @override
  String toString() => message;
}

final class OfflineSyncNotConfiguredFailure extends OfflineSyncFailure {
  const OfflineSyncNotConfiguredFailure([
    super.message = 'connectivity.sync.error.not_configured',
  ]);
}

final class OfflineSyncAttendanceUpsertFailure extends OfflineSyncFailure {
  const OfflineSyncAttendanceUpsertFailure([
    super.message = 'connectivity.sync.error.upsert_failed',
  ]);
}

/// Gyms occupancy UPDATE denied — do not invent RLS; escalate to Backend.
final class OfflineSyncOccupancyRlsFailure extends OfflineSyncFailure {
  const OfflineSyncOccupancyRlsFailure([
    super.message = 'connectivity.sync.error.occupancy_rls',
  ]);
}

final class OfflineSyncUnknownFailure extends OfflineSyncFailure {
  const OfflineSyncUnknownFailure([
    super.message = 'connectivity.sync.error.unknown',
  ]);
}
