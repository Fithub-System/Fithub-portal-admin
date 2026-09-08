import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fithub_portal_admin/core/network/supabase_config.dart';
import 'package:fithub_portal_admin/features/memberships/domain/entities/freeze_policy.dart';
import 'package:fithub_portal_admin/features/memberships/domain/entities/membership_plan.dart';
import 'package:fithub_portal_admin/features/memberships/domain/memberships_failure.dart';

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

  /// FEAT-61 — Admin JWT only.
  Future<String> renewMembership(String membershipId);

  /// FEAT-61 — Admin / Receptionist JWT.
  Future<String> freezeMembership({
    required String membershipId,
    int? days,
  });

  /// FEAT-61 — Admin / Receptionist JWT.
  Future<String> unfreezeMembership(String membershipId);

  Future<List<FreezePolicy>> listFreezePolicies();

  /// FEAT-61 — Admin JWT; [planId] null = general.
  Future<String> upsertFreezePolicy({
    required int freezeDays,
    required int maxFreezeDaysPerTime,
    String? planId,
  });
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
      final rows = activeOnly
          ? await client
                .from('membership_plans')
                .select(
                  'id, tenant_id, name, description, duration_days, '
                  'price_cents, currency, is_active',
                )
                .eq('is_active', true)
                .order('created_at', ascending: false)
          : await client
                .from('membership_plans')
                .select(
                  'id, tenant_id, name, description, duration_days, '
                  'price_cents, currency, is_active',
                )
                .order('created_at', ascending: false);
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

  @override
  Future<String> renewMembership(String membershipId) async {
    final client = _requireClient();
    try {
      final result = await client.rpc(
        'renew_membership',
        params: {'p_membership_id': membershipId},
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
  Future<String> freezeMembership({
    required String membershipId,
    int? days,
  }) async {
    final client = _requireClient();
    try {
      final params = <String, dynamic>{
        'p_membership_id': membershipId,
      };
      if (days != null) {
        params['p_days'] = days;
      }
      final result = await client.rpc('freeze_membership', params: params);
      return result as String;
    } on PostgrestException catch (e) {
      throw _mapException(e);
    } catch (e) {
      if (e is MembershipsFailure) rethrow;
      throw const MembershipsUnknownFailure();
    }
  }

  @override
  Future<String> unfreezeMembership(String membershipId) async {
    final client = _requireClient();
    try {
      final result = await client.rpc(
        'unfreeze_membership',
        params: {'p_membership_id': membershipId},
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
  Future<List<FreezePolicy>> listFreezePolicies() async {
    final client = _requireClient();
    try {
      final result = await client.rpc('list_freeze_policies');
      final rows = result as List<dynamic>? ?? const [];
      return rows
          .map((row) => _mapFreezePolicy(row as Map<String, dynamic>))
          .toList(growable: false);
    } on PostgrestException catch (e) {
      throw _mapException(e);
    } catch (e) {
      if (e is MembershipsFailure) rethrow;
      throw const MembershipsUnknownFailure();
    }
  }

  @override
  Future<String> upsertFreezePolicy({
    required int freezeDays,
    required int maxFreezeDaysPerTime,
    String? planId,
  }) async {
    final client = _requireClient();
    try {
      final result = await client.rpc(
        'upsert_freeze_policy',
        params: {
          'p_freeze_days': freezeDays,
          'p_max_freeze_days_per_time': maxFreezeDaysPerTime,
          'p_plan_id': planId,
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

  FreezePolicy _mapFreezePolicy(Map<String, dynamic> row) {
    return FreezePolicy(
      id: row['id'] as String,
      tenantId: row['tenant_id'] as String,
      planId: row['plan_id'] as String?,
      freezeDays: (row['freeze_days'] as num).toInt(),
      maxFreezeDaysPerTime: (row['max_freeze_days_per_time'] as num).toInt(),
    );
  }

  MembershipsFailure _mapException(PostgrestException e) {
    final code = e.code ?? '';
    final message = e.message.toLowerCase();
    if (code == '42501' || message.contains('forbidden')) {
      return const MembershipsForbiddenFailure();
    }
    if (code == '22023' || message.contains('invalid_input')) {
      if (message.contains('no freeze policy') ||
          message.contains('policy')) {
        return const MembershipsValidationFailure(
          'members.error.freeze_no_policy',
        );
      }
      return const MembershipsValidationFailure();
    }
    return const MembershipsUnknownFailure();
  }
}
