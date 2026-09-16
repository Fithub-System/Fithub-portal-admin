import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/postgrest_row.dart';
import '../../../../core/network/supabase_config.dart';
import '../../domain/entities/gym_occupancy.dart';
import 'gyms_occupancy_remote_data_source.dart';

/// Supabase PostgREST + Realtime adapter (default OCCUPANCY_BACKEND).
///
/// FEAT-92: live occupancy is COUNT of open visits (`checked_out_at IS NULL`).
/// Overlay that count on `gyms.current_occupancy` so a stale column cannot
/// blank the Home ring after a successful toggle.
class GymsOccupancySupabaseRemoteDataSource
    implements GymsOccupancyRemoteDataSource {
  GymsOccupancySupabaseRemoteDataSource({SupabaseClient? this._client});

  final SupabaseClient? _client;

  SupabaseClient? get _supabase {
    if (_client != null) return _client;
    if (!SupabaseConfig.isConfigured) return null;
    return Supabase.instance.client;
  }

  @override
  Future<GymOccupancy?> fetchOccupancy(String tenantId) async {
    final client = _supabase;
    if (client == null) return null;

    final row = await client
        .from('gyms')
        .select('id, name, current_occupancy, capacity_limit')
        .eq('id', tenantId)
        .maybeSingle();

    if (row == null) return null;
    return _withOpenVisits(client, tenantId, _fromRow(asJsonMap(row)));
  }

  @override
  Stream<GymOccupancy> watchOccupancy(String tenantId) {
    final client = _supabase;
    if (client == null) {
      return const Stream<GymOccupancy>.empty();
    }

    // Soft-fail empty snapshots (RLS / missing realtime publication).
    return client
        .from('gyms')
        .stream(primaryKey: ['id'])
        .eq('id', tenantId)
        .where((rows) => rows.isNotEmpty)
        .asyncMap((rows) async {
          final gym = _fromRow(asJsonMap(rows.first));
          return _withOpenVisits(client, tenantId, gym);
        });
  }

  Future<GymOccupancy> _withOpenVisits(
    SupabaseClient client,
    String tenantId,
    GymOccupancy gym,
  ) async {
    final live = await _countOpenVisits(client, tenantId);
    if (live == null) return gym;
    return GymOccupancy(
      id: gym.id,
      name: gym.name,
      currentOccupancy: live,
      capacityLimit: gym.capacityLimit,
    );
  }

  Future<int?> _countOpenVisits(SupabaseClient client, String tenantId) async {
    try {
      final rows = await client
          .from('attendance_logs')
          .select('id')
          .eq('tenant_id', tenantId)
          .isFilter('checked_out_at', null);
      return (rows as List<dynamic>).length;
    } catch (_) {
      return null;
    }
  }

  GymOccupancy _fromRow(Map<String, dynamic> row) {
    return GymOccupancy(
      id: row['id']?.toString() ?? '',
      name: row['name']?.toString() ?? '',
      currentOccupancy: asJsonInt(row['current_occupancy']),
      capacityLimit: asJsonInt(row['capacity_limit']),
    );
  }
}
