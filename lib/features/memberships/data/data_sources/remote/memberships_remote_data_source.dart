import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_config.dart';
import '../../domain/entities/membership_plan.dart';
import '../../domain/memberships_failure.dart';

abstract class MembershipsRemoteDataSource {
  Future<List<MembershipPlan>> listPlans({bool activeOnly = false});

  Future<MembershipPlan> createPlan({
    required String tenantId,
    required String name,
    String? description,
    required int durationDays,
    required int priceCents,
    String currency = 'EGP',
  });

  Future<void> deactivatePlan(String planId);

  Future<String> assignMembership({
    required String planId,
    required String athleteId,
  });

  Future<List<MembershipAthleteOption>> listEnrolledAthletes();
}

class MembershipsSupabaseRemoteDataSource
    implements MembershipsRemoteDataSource {
  MembershipsSupabaseRemoteDataSource({SupabaseClient? client})
    : _client = client;

  final SupabaseClient? _client;

  SupabaseClient? get _supabase {
    if (_client != null) return _client;
    if (!SupabaseConfig.isConfigured) return null;
    return Supabase.instance.client;
  }

  @override
  Future<List<MembershipPlan>> listPlans({bool activeOnly = false}) async {
    final client = _requireClient();
    try {
      var query = client.from('membership_plans').select(
        'id, tenant_id, name, description, duration_days, price_cents, '
        'currency, is_active',
      );
      if (activeOnly) {
        query = query.eq('is_active', true);
      }
      final rows = await query.order('created_at', ascending: false);
      return (rows as List<dynamic>)
          .map((row) => _mapPlan(row as Map<String, dynamic>))
          .toList(growable: false);
    } on PostgrestException catch (e) {
      throw _mapException(e);
    } catch (e) {
      if (e is MembershipsFailure) rethrow;
      throw const MembershipsUnknownFailure();
    }
  }

  @override
  Future<MembershipPlan> createPlan({
    required String tenantId,
    required String name,
    String? description,
    required int durationDays,
    required int priceCents,
    String currency = 'EGP',
  }) async {
    final client = _requireClient();
    try {
      final payload = <String, dynamic>{
        'tenant_id': tenantId,
        'name': name.trim(),
        'duration_days': durationDays,
        'price_cents': priceCents,
        'currency': currency,
        'is_active': true,
      };
      final trimmedDescription = description?.trim();
      if (trimmedDescription != null && trimmedDescription.isNotEmpty) {
        payload['description'] = trimmedDescription;
      }
      final row = await client
          .from('membership_plans')
          .insert(payload)
          .select(
            'id, tenant_id, name, description, duration_days, price_cents, '
            'currency, is_active',
          )
          .single();
      return _mapPlan(row);
    } on PostgrestException catch (e) {
      throw _mapException(e);
    } catch (e) {
      if (e is MembershipsFailure) rethrow;
      throw const MembershipsUnknownFailure();
    }
  }

  @override
  Future<void> deactivatePlan(String planId) async {
    final client = _requireClient();
    try {
      await client
          .from('membership_plans')
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', planId);
    } on PostgrestException catch (e) {
      throw _mapException(e);
    } catch (e) {
      if (e is MembershipsFailure) rethrow;
      throw const MembershipsUnknownFailure();
    }
  }

  @override
  Future<String> assignMembership({
    required String planId,
    required String athleteId,
  }) async {
    final client = _requireClient();
    try {
      final result = await client.rpc(
        'assign_membership',
        params: {
          'p_plan_id': planId,
          'p_athlete_id': athleteId,
        },
      );
      return result as String;
    } on PostgrestException catch (e) {
      throw _mapException(e);
    } catch (e) {
      if (e is MembershipsFailure) rethrow;
      throw const MembershipsUnknownFailure();
    }
  }

  @override
  Future<List<MembershipAthleteOption>> listEnrolledAthletes() async {
    final client = _requireClient();
    try {
      final rows = await client
          .from('athletes')
          .select('id, full_name')
          .order('full_name');
      return (rows as List<dynamic>)
          .map((row) {
            final map = row as Map<String, dynamic>;
            return MembershipAthleteOption(
              id: map['id'] as String,
              fullName: map['full_name'] as String,
            );
          })
          .toList(growable: false);
    } on PostgrestException catch (e) {
      throw _mapException(e);
    } catch (e) {
      if (e is MembershipsFailure) rethrow;
      throw const MembershipsUnknownFailure();
    }
  }

  SupabaseClient _requireClient() {
    final client = _supabase;
    if (client == null) {
      throw const MembershipsNotConfiguredFailure();
    }
    return client;
  }

  MembershipPlan _mapPlan(Map<String, dynamic> row) {
    return MembershipPlan(
      id: row['id'] as String,
      tenantId: row['tenant_id'] as String,
      name: row['name'] as String,
      description: row['description'] as String?,
      durationDays: (row['duration_days'] as num).toInt(),
      priceCents: (row['price_cents'] as num).toInt(),
      currency: row['currency'] as String? ?? 'EGP',
      isActive: row['is_active'] as bool? ?? true,
    );
  }

  MembershipsFailure _mapException(PostgrestException e) {
    final code = e.code ?? '';
    final message = e.message.toLowerCase();
    if (code == '42501' || message.contains('forbidden')) {
      return const MembershipsForbiddenFailure();
    }
    if (code == '22023' || message.contains('invalid_input')) {
      return const MembershipsValidationFailure();
    }
    return const MembershipsUnknownFailure();
  }
}
