import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_config.dart';
import '../../domain/entities/gym_occupancy.dart';
import '../../domain/repositories/gyms_occupancy_repository.dart';

/// Supabase-backed gym occupancy (SELECT + realtime). Accept-Language via
/// [SupabaseLocaleHeaders] on client init / locale change (FEAT-03).
///
/// **Backend note:** `gyms_employee_select_policy` allows SELECT only.
/// Occupancy UPDATE RLS is not invented here — report to Backend if writes fail.
class GymsOccupancyRepositoryImpl implements GymsOccupancyRepository {
  GymsOccupancyRepositoryImpl({SupabaseClient? this._client});

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

    return client
        .from('gyms')
        .stream(primaryKey: ['id'])
        .eq('id', tenantId)
        .map((rows) {
          if (rows.isEmpty) {
            throw StateError('No gym row for tenant $tenantId');
          }
          return _fromRow(Map<String, dynamic>.from(rows.first));
        });
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
