import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/postgrest_row.dart';
import '../../../../core/network/supabase_config.dart';
import 'overview_metrics_remote_data_source.dart';

/// User-JWT Supabase reads for Home Overview KPIs — never service_role.
///
/// PostgREST / mapping errors propagate so Overview can surface
/// `dashboard.metrics.load_failed` instead of silent zeros (P0).
class OverviewMetricsSupabaseRemoteDataSource
    implements OverviewMetricsRemoteDataSource {
  OverviewMetricsSupabaseRemoteDataSource({SupabaseClient? client})
    : _client = client;

  final SupabaseClient? _client;

  SupabaseClient? get _supabase {
    if (_client != null) return _client;
    if (!SupabaseConfig.isConfigured) return null;
    return Supabase.instance.client;
  }

  @override
  Future<int> countCheckInsSince({
    required String tenantId,
    required DateTime dayStartUtc,
  }) async {
    final client = _requireClient();
    final rows = await client
        .from('attendance_logs')
        .select('id')
        .eq('tenant_id', tenantId)
        .gte('checked_in_at', dayStartUtc.toUtc().toIso8601String());
    return asJsonMapList(rows).length;
  }

  @override
  Future<({int totalCents, String currency})> sumPaidChargesSince({
    required String tenantId,
    required DateTime dayStartUtc,
  }) async {
    final client = _requireClient();
    final rows = await client
        .from('membership_charges')
        .select('amount_cents, currency, paid_at, status')
        .eq('tenant_id', tenantId)
        .eq('status', 'paid')
        .gte('paid_at', dayStartUtc.toUtc().toIso8601String());

    var total = 0;
    var currency = 'EGP';
    for (final data in asJsonMapList(rows)) {
      total += asJsonInt(data['amount_cents']);
      final c = data['currency']?.toString();
      if (c != null && c.isNotEmpty) currency = c;
    }
    return (totalCents: total, currency: currency);
  }

  @override
  Future<int> countGymMembers({required String tenantId}) async {
    final client = _requireClient();
    final rows = await client
        .from('gym_members')
        .select('athlete_id')
        .eq('tenant_id', tenantId);
    return asJsonMapList(rows).length;
  }

  SupabaseClient _requireClient() {
    final client = _supabase;
    if (client == null) {
      throw StateError('Supabase is not configured for Overview KPIs');
    }
    return client;
  }
}
