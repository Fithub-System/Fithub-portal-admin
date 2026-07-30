import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fithub_portal_admin/core/network/supabase_config.dart';
import 'package:fithub_portal_admin/features/billing/domain/billing_failure.dart';
import 'package:fithub_portal_admin/features/billing/domain/entities/membership_charge.dart';

abstract class BillingRemoteDataSource {
  Future<List<MembershipCharge>> listCharges({
    required String tenantId,
    int limit = 50,
  });

  Future<MembershipCharge> updateChargeStatus({
    required String chargeId,
    required MembershipChargeStatus status,
  });

  Future<int> applyBillingFreeze({required String tenantId});
}

/// User-JWT Supabase client only — never service_role (FEAT-08 AC-E1).
class BillingSupabaseRemoteDataSource implements BillingRemoteDataSource {
  BillingSupabaseRemoteDataSource({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;

  static const _selectColumns =
      'id, tenant_id, athlete_id, athlete_membership_id, plan_id, '
      'amount_cents, currency, status, due_at, paid_at, '
      'athletes(full_name), membership_plans(name)';

  SupabaseClient? get _supabase {
    if (_client != null) return _client;
    if (!SupabaseConfig.isConfigured) return null;
    return Supabase.instance.client;
  }

  @override
  Future<List<MembershipCharge>> listCharges({
    required String tenantId,
    int limit = 50,
  }) async {
    final client = _requireClient();
    try {
      final rows = await client
          .from('membership_charges')
          .select(_selectColumns)
          .eq('tenant_id', tenantId)
          .order('due_at', ascending: false)
          .limit(limit);
      return (rows as List<dynamic>)
          .map((row) => _mapCharge(row as Map<String, dynamic>))
          .toList(growable: false);
    } on PostgrestException catch (e) {
      throw _mapException(e);
    } catch (e) {
      if (e is BillingFailure) rethrow;
      throw const BillingUnknownFailure();
    }
  }

  @override
  Future<MembershipCharge> updateChargeStatus({
    required String chargeId,
    required MembershipChargeStatus status,
  }) async {
    final client = _requireClient();
    try {
      final row = await client
          .from('membership_charges')
          .update({'status': status.apiValue})
          .eq('id', chargeId)
          .select(_selectColumns)
          .single();
      return _mapCharge(row);
    } on PostgrestException catch (e) {
      throw _mapException(e);
    } catch (e) {
      if (e is BillingFailure) rethrow;
      throw const BillingUnknownFailure();
    }
  }

  @override
  Future<int> applyBillingFreeze({required String tenantId}) async {
    final client = _requireClient();
    try {
      final result = await client.rpc(
        'apply_billing_freeze',
        params: {'p_tenant_id': tenantId},
      );
      if (result is int) return result;
      if (result is num) return result.toInt();
      return int.tryParse('$result') ?? 0;
    } on PostgrestException catch (e) {
      throw _mapException(e);
    } catch (e) {
      if (e is BillingFailure) rethrow;
      throw const BillingUnknownFailure();
    }
  }

  SupabaseClient _requireClient() {
    final client = _supabase;
    if (client == null) {
      throw const BillingNotConfiguredFailure();
    }
    return client;
  }

  MembershipCharge _mapCharge(Map<String, dynamic> row) {
    final athletes = row['athletes'];
    final plans = row['membership_plans'];
    String? athleteName;
    String? planName;
    if (athletes is Map<String, dynamic>) {
      athleteName = athletes['full_name'] as String?;
    }
    if (plans is Map<String, dynamic>) {
      planName = plans['name'] as String?;
    }
    return MembershipCharge(
      id: row['id'] as String,
      tenantId: row['tenant_id'] as String,
      athleteId: row['athlete_id'] as String,
      athleteMembershipId: row['athlete_membership_id'] as String,
      planId: row['plan_id'] as String,
      amountCents: (row['amount_cents'] as num).toInt(),
      currency: row['currency'] as String? ?? 'EGP',
      status: MembershipChargeStatus.fromApi(row['status'] as String? ?? ''),
      dueAt: DateTime.parse(row['due_at'] as String),
      paidAt: row['paid_at'] == null
          ? null
          : DateTime.parse(row['paid_at'] as String),
      athleteName: athleteName,
      planName: planName,
    );
  }

  BillingFailure _mapException(PostgrestException e) {
    final code = e.code ?? '';
    final message = e.message.toLowerCase();
    if (code == '42501' || message.contains('forbidden')) {
      return const BillingForbiddenFailure();
    }
    if (code == '22023' || message.contains('invalid')) {
      return const BillingValidationFailure();
    }
    return const BillingUnknownFailure();
  }
}
