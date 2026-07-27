import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_config.dart';
import '../../domain/entities/gym_occupancy.dart';
import 'gyms_occupancy_remote_data_source.dart';

/// Supabase PostgREST + Realtime adapter (default OCCUPANCY_BACKEND).
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
    return _fromRow(Map<String, dynamic>.from(row));
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
        .map((rows) => _fromRow(Map<String, dynamic>.from(rows.first)));
  }

  GymOccupancy _fromRow(Map<String, dynamic> row) {
    return GymOccupancy(
      id: row['id'] as String,
      name: row['name'] as String? ?? '',
      currentOccupancy: _asInt(row['current_occupancy']),
      capacityLimit: _asInt(row['capacity_limit']),
    );
  }

  int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }
}
