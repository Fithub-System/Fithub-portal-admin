import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_config.dart';
import 'overview_metrics_remote_data_source.dart';

/// User-JWT Supabase reads for Home Overview KPIs — never service_role.
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
    final client = _supabase;
    if (client == null) return 0;

    try {
      final rows = await client
          .from('attendance_logs')
          .select('id')
          .eq('tenant_id', tenantId)
          .gte('checked_in_at', dayStartUtc.toUtc().toIso8601String());
      return (rows as List<dynamic>).length;
    } on PostgrestException {
      return 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Future<({int totalCents, String currency})> sumPaidChargesSince({
    required String tenantId,
    required DateTime dayStartUtc,
  }) async {
    final client = _supabase;
    if (client == null) {
      return (totalCents: 0, currency: 'EGP');
    }

    try {
      final rows = await client
          .from('membership_charges')
          .select('amount_cents, currency, paid_at, status')
          .eq('tenant_id', tenantId)
          .eq('status', 'paid')
          .gte('paid_at', dayStartUtc.toUtc().toIso8601String());

      var total = 0;
      var currency = 'EGP';
      for (final row in rows as List<dynamic>) {
        final data = row as Map<String, dynamic>;
        total += (data['amount_cents'] as num?)?.toInt() ?? 0;
        final c = data['currency'] as String?;
        if (c != null && c.isNotEmpty) currency = c;
      }
      return (totalCents: total, currency: currency);
    } on PostgrestException {
      return (totalCents: 0, currency: 'EGP');
    } catch (_) {
      return (totalCents: 0, currency: 'EGP');
    }
  }
}
