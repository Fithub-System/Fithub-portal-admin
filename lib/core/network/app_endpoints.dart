import 'network_config.dart';

/// Stable HTTP contract for gym occupancy (FEAT-04 §4).
///
/// Paths are host-agnostic — same shapes for Nest/FastAPI or any REST host.
/// Supabase PostgREST paths are adapter-only and never referenced from UI.
abstract final class AppEndpoints {
  static String get _root => NetworkConfig.baseUrl;

  /// `GET /v1/gyms/{tenantId}/occupancy`
  ///
  /// Response JSON (snake_case):
  /// `{ id, name, current_occupancy, capacity_limit }`
  static String gymOccupancy(String tenantId) =>
      '$_root/v1/gyms/$tenantId/occupancy';

  /// Live occupancy stream contract (WS or SSE).
  ///
  /// `WS/SSE /v1/gyms/{tenantId}/occupancy/stream`
  /// Payload per event matches [gymOccupancy] response body.
  static String gymOccupancyStream(String tenantId) =>
      '$_root/v1/gyms/$tenantId/occupancy/stream';

  /// FEAT-05 staff invite Edge Function (user JWT only).
  ///
  /// `POST /functions/v1/invite-staff`
  /// Body JSON: `{ email, role, name }` where role ∈ Admin|Receptionist|Coach.
  static String get inviteStaff => '$_root/functions/v1/invite-staff';
}
