import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fithub_portal_admin/core/network/supabase_config.dart';
import 'package:fithub_portal_admin/features/gym_sku_settings/data/models/gym_sku_settings_model.dart';
import 'package:fithub_portal_admin/features/gym_sku_settings/domain/entities/gym_sku_settings.dart';
import 'package:fithub_portal_admin/features/gym_sku_settings/domain/gym_sku_settings_failure.dart';

abstract class GymSkuSettingsRemoteDataSource {
  Future<GymSkuSettingsModel> fetchSettings({required String tenantId});

  /// RPC only — never PATCH `gyms.sku_mode` / `marketplace_opt_in` (AC-D2).
  Future<GymSkuSettingsModel> setGymSkuSettings({
    required SkuMode skuMode,
    required bool marketplaceOptIn,
  });
}

/// User-JWT Supabase client only — never service_role (AC-E1).
class GymSkuSettingsSupabaseRemoteDataSource
    implements GymSkuSettingsRemoteDataSource {
  GymSkuSettingsSupabaseRemoteDataSource({SupabaseClient? client})
    : _client = client;

  final SupabaseClient? _client;

  static const _selectColumns = 'id, sku_mode, marketplace_opt_in';

  SupabaseClient? get _supabase {
    if (_client != null) return _client;
    if (!SupabaseConfig.isConfigured) return null;
    return Supabase.instance.client;
  }

  @override
  Future<GymSkuSettingsModel> fetchSettings({required String tenantId}) async {
    final client = _requireClient();
    try {
      final row = await client
          .from('gyms')
          .select(_selectColumns)
          .eq('id', tenantId)
          .single();
      return GymSkuSettingsModel.fromJson(row);
    } on PostgrestException catch (e) {
      throw _mapException(e);
    } catch (e) {
      if (e is GymSkuSettingsFailure) rethrow;
      throw const GymSkuSettingsUnknownFailure();
    }
  }

  @override
  Future<GymSkuSettingsModel> setGymSkuSettings({
    required SkuMode skuMode,
    required bool marketplaceOptIn,
  }) async {
    final client = _requireClient();
    try {
      final result = await client.rpc(
        'set_gym_sku_settings',
        params: {
          'p_sku_mode': skuMode.apiValue,
          'p_marketplace_opt_in': marketplaceOptIn,
        },
      );
      final map = _asJsonMap(result);
      if (map == null) {
        throw const GymSkuSettingsUnknownFailure();
      }
      return GymSkuSettingsModel.fromJson(map);
    } on PostgrestException catch (e) {
      throw _mapException(e);
    } catch (e) {
      if (e is GymSkuSettingsFailure) rethrow;
      throw const GymSkuSettingsUnknownFailure();
    }
  }

  SupabaseClient _requireClient() {
    final client = _supabase;
    if (client == null) {
      throw const GymSkuSettingsNotConfiguredFailure();
    }
    return client;
  }

  Map<String, dynamic>? _asJsonMap(dynamic result) {
    if (result is Map<String, dynamic>) return result;
    if (result is Map) {
      return Map<String, dynamic>.from(result);
    }
    return null;
  }

  GymSkuSettingsFailure _mapException(PostgrestException e) {
    final code = e.code ?? '';
    final message = e.message.toLowerCase();
    if (code == '42501' || message.contains('forbidden')) {
      return const GymSkuSettingsForbiddenFailure();
    }
    if (code == '22023' || message.contains('invalid')) {
      return const GymSkuSettingsValidationFailure();
    }
    return const GymSkuSettingsUnknownFailure();
  }
}
