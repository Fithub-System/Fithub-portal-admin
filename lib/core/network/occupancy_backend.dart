/// Selects the gym occupancy remote adapter (FEAT-04 AC-D3).
///
/// `--dart-define=OCCUPANCY_BACKEND=supabase|http` (default: `supabase`).
enum OccupancyBackend { supabase, http }

abstract final class OccupancyBackendConfig {
  static const String _raw = String.fromEnvironment(
    'OCCUPANCY_BACKEND',
    defaultValue: 'supabase',
  );

  static OccupancyBackend get current {
    switch (_raw.trim().toLowerCase()) {
      case 'http':
        return OccupancyBackend.http;
      case 'supabase':
      default:
        return OccupancyBackend.supabase;
    }
  }

  static bool get isHttp => current == OccupancyBackend.http;
  static bool get isSupabase => current == OccupancyBackend.supabase;
}
