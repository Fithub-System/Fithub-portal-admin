import 'package:fithub_portal_admin/core/network/postgrest_row.dart';
import 'package:fithub_portal_admin/core/network/supabase_config.dart';
import 'package:fithub_portal_admin/core/storage/secure_storage_service.dart';
import 'package:fithub_portal_admin/features/auth/data/models/employee_profile_model.dart';
import 'package:fithub_portal_admin/features/auth/domain/auth_failure.dart';
import 'package:fithub_portal_admin/features/auth/domain/entities/employee_profile.dart';
import 'package:fithub_portal_admin/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required SecureStorageService secureStorage,
    SupabaseClient? client,
  }) : _secureStorage = secureStorage,
       _client = client;

  final SecureStorageService _secureStorage;
  final SupabaseClient? _client;

  static const _cachePrefix = 'portal_employee_';
  static const _allowedRoles = {'Admin', 'Receptionist'};

  SupabaseClient get _supabase {
    final injected = _client;
    if (injected != null) return injected;
    if (!SupabaseConfig.isConfigured) {
      throw const AuthNotConfiguredFailure();
    }
    return Supabase.instance.client;
  }

  @override
  Session? get currentSession {
    try {
      return _supabase.auth.currentSession;
    } on AuthFailure {
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<EmployeeProfile> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      if (response.session == null || response.user == null) {
        throw const InvalidCredentialsFailure();
      }
      return resolveEmployeeProfile();
    } on AuthFailure {
      rethrow;
    } on AuthException {
      throw const InvalidCredentialsFailure();
    } catch (e) {
      if (e is AuthFailure) rethrow;
      throw const AuthUnknownFailure();
    }
  }

  @override
  Future<EmployeeProfile?> signUpGymFounder({
    required String email,
    required String password,
    required String tradingName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'trading_name': tradingName.trim(),
          'gym_founder': true,
        },
        emailRedirectTo: 'https://fitness-hub.app',
      );
      if (response.user == null) {
        throw const AuthUnknownFailure();
      }
      if (response.session == null) {
        return null;
      }
      await _bootstrapFounder(tradingName.trim());
      return resolveEmployeeProfile();
    } on AuthFailure {
      rethrow;
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('already') || msg.contains('registered')) {
        throw const InvalidCredentialsFailure('auth.error.email_taken');
      }
      throw InvalidCredentialsFailure(e.message);
    } catch (e) {
      if (e is AuthFailure) rethrow;
      throw const AuthUnknownFailure();
    }
  }

  Future<void> _bootstrapFounder(String tradingName) async {
    await _supabase.rpc(
      'bootstrap_gym_founder',
      params: {
        'p_trading_name': tradingName,
        'p_contact_name': tradingName,
      },
    );
  }

  @override
  Future<EmployeeProfile> resolveEmployeeProfile() async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) {
      throw const InvalidCredentialsFailure('auth.error.no_session');
    }

    Map<String, dynamic>? row;
    try {
      // FEAT-02 §4.2 — employees where user_id = auth.uid()
      row = await _supabase
          .from('employees')
          .select('id, tenant_id, user_id, name, role, created_at')
          .eq('user_id', uid)
          .maybeSingle();
    } on PostgrestException catch (e) {
      await signOut();
      // Surface PostgREST/RLS/GRANT failures (often look like "nothing happened").
      throw AuthUnknownFailure(
        'Profile resolve failed (${e.code}): ${e.message}',
      );
    }

    if (row == null) {
      final meta = _supabase.auth.currentUser?.userMetadata ?? {};
      final founder = meta['gym_founder'] == true;
      final trading = meta['trading_name']?.toString().trim() ?? '';
      if (founder && trading.isNotEmpty) {
        try {
          await _bootstrapFounder(trading);
          row = await _supabase
              .from('employees')
              .select('id, tenant_id, user_id, name, role, created_at')
              .eq('user_id', uid)
              .maybeSingle();
        } on PostgrestException catch (e) {
          await signOut();
          throw AuthUnknownFailure(
            'Founder bootstrap failed (${e.code}): ${e.message}',
          );
        }
      }
    }

    if (row == null) {
      await signOut();
      throw const EmployeeProfileMissingFailure();
    }

    final profileJson = Map<String, dynamic>.from(asJsonMap(row));
    try {
      final gym = await _supabase
          .from('gyms')
          .select('onboarding_status')
          .eq('id', profileJson['tenant_id'])
          .maybeSingle();
      profileJson['onboarding_status'] =
          gym?['onboarding_status']?.toString() ?? 'active';
    } catch (_) {
      profileJson['onboarding_status'] = 'active';
    }

    final profile = EmployeeProfileModel.fromJson(profileJson);

    // Portal M1: Admin | Receptionist only (deny Coach).
    if (!_allowedRoles.contains(profile.role)) {
      await signOut();
      throw const WrongAppRoleFailure();
    }

    try {
      await _cacheProfile(profile);
    } catch (_) {
      // Cache is best-effort; do not block shell entry (web secure storage).
    }
    return profile;
  }

  @override
  Future<void> signOut() async {
    await _clearCache();
    try {
      await _supabase.auth.signOut();
    } catch (_) {
      // Session may already be invalid.
    }
  }

  @override
  Future<EmployeeProfile?> readCachedProfile() async {
    final id = await _secureStorage.read(key: '${_cachePrefix}id');
    final tenantId = await _secureStorage.read(key: '${_cachePrefix}tenant_id');
    final userId = await _secureStorage.read(key: '${_cachePrefix}user_id');
    final name = await _secureStorage.read(key: '${_cachePrefix}name');
    final role = await _secureStorage.read(key: '${_cachePrefix}role');
    final onboarding =
        await _secureStorage.read(key: '${_cachePrefix}onboarding_status');
    if (id == null ||
        tenantId == null ||
        userId == null ||
        name == null ||
        role == null) {
      return null;
    }

    return EmployeeProfileModel.fromCache({
      'id': id,
      'tenant_id': tenantId,
      'user_id': userId,
      'name': name,
      'role': role,
      'onboarding_status': onboarding ?? 'active',
    });
  }

  Future<void> _cacheProfile(EmployeeProfileModel profile) async {
    for (final entry in profile.toCacheMap().entries) {
      await _secureStorage.write(
        key: '$_cachePrefix${entry.key}',
        value: entry.value,
      );
    }
  }

  Future<void> _clearCache() async {
    for (final key in [
      'id',
      'tenant_id',
      'user_id',
      'name',
      'role',
      'onboarding_status',
    ]) {
      await _secureStorage.delete(key: '$_cachePrefix$key');
    }
  }
}
