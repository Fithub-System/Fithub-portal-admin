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
  })  : _secureStorage = secureStorage,
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
  Future<EmployeeProfile> resolveEmployeeProfile() async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) {
      throw const InvalidCredentialsFailure('auth.error.no_session');
    }

    // FEAT-02 §4.2 — employees where user_id = auth.uid()
    final row = await _supabase
        .from('employees')
        .select('id, tenant_id, user_id, name, role, created_at')
        .eq('user_id', uid)
        .maybeSingle();

    if (row == null) {
      await signOut();
      throw const EmployeeProfileMissingFailure();
    }

    final profile = EmployeeProfileModel.fromJson(row);

    // Portal M1: Admin | Receptionist only (deny Coach).
    if (!_allowedRoles.contains(profile.role)) {
      await signOut();
      throw const WrongAppRoleFailure();
    }

    await _cacheProfile(profile);
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
    for (final key in ['id', 'tenant_id', 'user_id', 'name', 'role']) {
      await _secureStorage.delete(key: '$_cachePrefix$key');
    }
  }
}
