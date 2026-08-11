import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fithub_portal_admin/core/network/supabase_config.dart';
import 'package:fithub_portal_admin/features/admin_payout_queue/domain/admin_payout_failure.dart';
import 'package:fithub_portal_admin/features/admin_payout_queue/domain/entities/coach_payout_request.dart';

abstract class AdminPayoutQueueRemoteDataSource {
  Future<List<CoachPayoutRequest>> listRequests({int limit = 100});

  Future<CoachPayoutRequest> fulfill({
    required String requestId,
    required AdminPayoutFulfillAction action,
  });
}

/// User-JWT Supabase client only — never service_role (FEAT-30).
///
/// View: `coach_payout_requests_for_admin`
/// RPC: `admin_fulfill_coach_payout(p_request_id, p_action)`
class AdminPayoutQueueSupabaseRemoteDataSource
    implements AdminPayoutQueueRemoteDataSource {
  AdminPayoutQueueSupabaseRemoteDataSource({SupabaseClient? client})
      : _client = client;

  final SupabaseClient? _client;

  static const _selectColumns =
      'id, tenant_id, coach_employee_id, coach_display_name, '
      'amount_cents, currency, status, created_at, updated_at';

  SupabaseClient? get _supabase {
    if (_client != null) return _client;
    if (!SupabaseConfig.isConfigured) return null;
    return Supabase.instance.client;
  }

  @override
  Future<List<CoachPayoutRequest>> listRequests({int limit = 100}) async {
    final client = _requireClient();
    try {
      final rows = await client
          .from('coach_payout_requests_for_admin')
          .select(_selectColumns)
          .order('created_at', ascending: false)
          .limit(limit);
      return (rows as List<dynamic>)
          .map((row) => _mapRequest(row as Map<String, dynamic>))
          .toList(growable: false);
    } on PostgrestException catch (e) {
      throw _mapException(e);
    } catch (e) {
      if (e is AdminPayoutFailure) rethrow;
      throw const AdminPayoutUnknownFailure();
    }
  }

  @override
  Future<CoachPayoutRequest> fulfill({
    required String requestId,
    required AdminPayoutFulfillAction action,
  }) async {
    final client = _requireClient();
    try {
      final result = await client.rpc(
        'admin_fulfill_coach_payout',
        params: {
          'p_request_id': requestId,
          'p_action': action.apiValue,
        },
      );
      if (result is Map) {
        return _mapRequest(Map<String, dynamic>.from(result));
      }
      // Some RPC shapes return void / bool — re-fetch row by id via view.
      final rows = await client
          .from('coach_payout_requests_for_admin')
          .select(_selectColumns)
          .eq('id', requestId)
          .limit(1);
      final list = rows as List<dynamic>;
      if (list.isEmpty) {
        throw const AdminPayoutNotFoundFailure();
      }
      return _mapRequest(list.first as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw _mapException(e);
    } catch (e) {
      if (e is AdminPayoutFailure) rethrow;
      throw const AdminPayoutUnknownFailure();
    }
  }

  SupabaseClient _requireClient() {
    final client = _supabase;
    if (client == null) {
      throw const AdminPayoutNotConfiguredFailure();
    }
    return client;
  }

  CoachPayoutRequest _mapRequest(Map<String, dynamic> row) {
    final name = row['coach_display_name'];
    return CoachPayoutRequest(
      id: '${row['id']}',
      tenantId: '${row['tenant_id']}',
      coachEmployeeId: '${row['coach_employee_id']}',
      coachDisplayName: (name is String && name.trim().isNotEmpty)
          ? name.trim()
          : '—',
      amountCents: _asInt(row['amount_cents']),
      currency: (row['currency'] as String?)?.toUpperCase() ?? 'EGP',
      status: CoachPayoutRequestStatus.fromApi('${row['status'] ?? 'pending'}'),
      createdAt: _asDate(row['created_at']) ?? DateTime.now().toUtc(),
      updatedAt: _asDate(row['updated_at']),
    );
  }

  AdminPayoutFailure _mapException(PostgrestException e) {
    final msg = (e.message).toLowerCase();
    final details = (e.details?.toString() ?? '').toLowerCase();
    final hint = (e.hint ?? '').toLowerCase();
    final blob = '$msg $details $hint';

    if (blob.contains('forbidden') ||
        blob.contains('admin only') ||
        e.code == '42501') {
      return const AdminPayoutForbiddenFailure();
    }
    if (blob.contains('not_found') || blob.contains('not found')) {
      return const AdminPayoutNotFoundFailure();
    }
    if (blob.contains('invalid_state') || blob.contains('not pending')) {
      return const AdminPayoutInvalidStateFailure();
    }
    if (blob.contains('invalid_input') || blob.contains('invalid input')) {
      return const AdminPayoutInvalidInputFailure();
    }
    return const AdminPayoutUnknownFailure();
  }

  static int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  static DateTime? _asDate(Object? value) {
    if (value is DateTime) return value.toUtc();
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value)?.toUtc();
    }
    return null;
  }
}
