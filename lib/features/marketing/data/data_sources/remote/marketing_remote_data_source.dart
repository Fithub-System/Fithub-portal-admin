import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fithub_portal_admin/core/network/postgrest_row.dart';
import 'package:fithub_portal_admin/core/network/supabase_config.dart';
import 'package:fithub_portal_admin/features/marketing/domain/entities/marketing_campaign.dart';
import 'package:fithub_portal_admin/features/marketing/domain/entities/promo_code.dart';
import 'package:fithub_portal_admin/features/marketing/domain/marketing_failure.dart';

abstract class MarketingRemoteDataSource {
  Future<List<MarketingCampaign>> listCampaigns();

  Future<List<PromoCode>> listPromoCodes();

  Future<MarketingCampaign> upsertCampaign({
    String? id,
    required String name,
    required DateTime startsAt,
    required DateTime endsAt,
    required bool pushEnabled,
    String status = 'scheduled',
  });

  Future<PromoCode> upsertPromoCode({
    String? id,
    required String code,
    int? percentOff,
    int? amountOffCents,
    String currency = 'EGP',
    DateTime? expiresAt,
    String status = 'active',
  });
}

/// User-JWT Supabase client only — never service_role (FEAT-23).
class MarketingSupabaseRemoteDataSource implements MarketingRemoteDataSource {
  MarketingSupabaseRemoteDataSource({SupabaseClient? client})
    : _client = client;

  final SupabaseClient? _client;

  SupabaseClient? get _supabase {
    if (_client != null) return _client;
    if (!SupabaseConfig.isConfigured) return null;
    return Supabase.instance.client;
  }

  @override
  Future<List<MarketingCampaign>> listCampaigns() async {
    final client = _requireClient();
    try {
      final rows = await client
          .from('marketing_campaigns')
          .select(
            'id, tenant_id, name, starts_at, ends_at, push_enabled, '
            'status, created_at, updated_at',
          )
          .order('starts_at', ascending: false);
      return asJsonMapList(rows).map(_mapCampaign).toList(growable: false);
    } on PostgrestException catch (e) {
      throw _mapException(e);
    } catch (e) {
      if (e is MarketingFailure) rethrow;
      throw const MarketingUnknownFailure();
    }
  }

  @override
  Future<List<PromoCode>> listPromoCodes() async {
    final client = _requireClient();
    try {
      final rows = await client
          .from('promo_codes')
          .select(
            'id, tenant_id, code, percent_off, amount_off_cents, currency, '
            'expires_at, status, redeemed_count, created_at, updated_at',
          )
          .order('created_at', ascending: false);
      return asJsonMapList(rows).map(_mapPromo).toList(growable: false);
    } on PostgrestException catch (e) {
      throw _mapException(e);
    } catch (e) {
      if (e is MarketingFailure) rethrow;
      throw const MarketingUnknownFailure();
    }
  }

  @override
  Future<MarketingCampaign> upsertCampaign({
    String? id,
    required String name,
    required DateTime startsAt,
    required DateTime endsAt,
    required bool pushEnabled,
    String status = 'scheduled',
  }) async {
    final client = _requireClient();
    try {
      final result = await client.rpc(
        'upsert_marketing_campaign',
        params: {
          'p_id': id,
          'p_name': name.trim(),
          'p_starts_at': startsAt.toUtc().toIso8601String(),
          'p_ends_at': endsAt.toUtc().toIso8601String(),
          'p_push_enabled': pushEnabled,
          'p_status': status,
        },
      );
      return _mapCampaign(asJsonMap(result));
    } on PostgrestException catch (e) {
      throw _mapException(e);
    } catch (e) {
      if (e is MarketingFailure) rethrow;
      throw const MarketingUnknownFailure();
    }
  }

  @override
  Future<PromoCode> upsertPromoCode({
    String? id,
    required String code,
    int? percentOff,
    int? amountOffCents,
    String currency = 'EGP',
    DateTime? expiresAt,
    String status = 'active',
  }) async {
    final client = _requireClient();
    try {
      final result = await client.rpc(
        'upsert_promo_code',
        params: {
          'p_id': id,
          'p_code': code.trim(),
          'p_percent_off': percentOff,
          'p_amount_off_cents': amountOffCents,
          'p_currency': currency,
          'p_expires_at': expiresAt?.toUtc().toIso8601String(),
          'p_status': status,
        },
      );
      return _mapPromo(asJsonMap(result));
    } on PostgrestException catch (e) {
      throw _mapException(e);
    } catch (e) {
      if (e is MarketingFailure) rethrow;
      throw const MarketingUnknownFailure();
    }
  }

  SupabaseClient _requireClient() {
    final client = _supabase;
    if (client == null) {
      throw const MarketingNotConfiguredFailure();
    }
    return client;
  }

  MarketingCampaign _mapCampaign(Map<String, dynamic> row) {
    return MarketingCampaign(
      id: jsonStringOrNull(row['id']) ?? '',
      tenantId: jsonStringOrNull(row['tenant_id']) ?? '',
      name: jsonStringOrNull(row['name']) ?? '',
      startsAt: parseJsonUtc(row['starts_at']) ?? DateTime.now().toUtc(),
      endsAt: parseJsonUtc(row['ends_at']) ?? DateTime.now().toUtc(),
      pushEnabled: jsonBool(row['push_enabled']),
      status: jsonStringOrNull(row['status']) ?? 'scheduled',
      createdAt: parseJsonUtc(row['created_at']),
      updatedAt: parseJsonUtc(row['updated_at']),
    );
  }

  PromoCode _mapPromo(Map<String, dynamic> row) {
    return PromoCode(
      id: jsonStringOrNull(row['id']) ?? '',
      tenantId: jsonStringOrNull(row['tenant_id']) ?? '',
      code: jsonStringOrNull(row['code']) ?? '',
      percentOff: row['percent_off'] == null
          ? null
          : asJsonInt(row['percent_off']),
      amountOffCents: row['amount_off_cents'] == null
          ? null
          : asJsonInt(row['amount_off_cents']),
      currency: jsonStringOrNull(row['currency']) ?? 'EGP',
      expiresAt: parseJsonUtc(row['expires_at']),
      status: jsonStringOrNull(row['status']) ?? 'active',
      redeemedCount: asJsonInt(row['redeemed_count']),
      createdAt: parseJsonUtc(row['created_at']),
      updatedAt: parseJsonUtc(row['updated_at']),
    );
  }

  MarketingFailure _mapException(PostgrestException e) {
    final code = e.code ?? '';
    final message = e.message.toLowerCase();
    if (code == '42501' || message.contains('forbidden')) {
      return const MarketingForbiddenFailure();
    }
    if (code == '22023' ||
        code == '23505' ||
        message.contains('invalid') ||
        message.contains('unique') ||
        message.contains('check')) {
      return const MarketingValidationFailure();
    }
    return const MarketingUnknownFailure();
  }
}
