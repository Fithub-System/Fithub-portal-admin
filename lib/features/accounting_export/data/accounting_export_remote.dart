import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fithub_portal_admin/core/network/supabase_config.dart';

/// FEAT-89/90 Admin RPCs — user JWT only.
class AccountingExportRemote {
  AccountingExportRemote({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;

  SupabaseClient get _supabase {
    final c = _client ??
        (SupabaseConfig.isConfigured ? Supabase.instance.client : null);
    if (c == null) {
      throw StateError('supabase_not_configured');
    }
    return c;
  }

  Future<String> exportCsv({
    required String dataset,
    required DateTime from,
    required DateTime to,
  }) async {
    final result = await _supabase.rpc(
      'export_tenant_accounting_csv',
      params: {
        'p_dataset': dataset,
        'p_from': from.toUtc().toIso8601String(),
        'p_to': to.toUtc().toIso8601String(),
      },
    );
    return '$result';
  }

  Future<Map<String, dynamic>> getInvoice(String orderId) async {
    final result = await _supabase.rpc(
      'get_payment_invoice',
      params: {'p_order_id': orderId},
    );
    if (result is Map) {
      return Map<String, dynamic>.from(result);
    }
    throw StateError('invalid_invoice_payload');
  }
}
