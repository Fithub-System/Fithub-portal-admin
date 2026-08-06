import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fithub_portal_admin/core/network/supabase_config.dart';
import 'package:fithub_portal_admin/features/class_sessions/domain/class_sessions_failure.dart';
import 'package:fithub_portal_admin/features/class_sessions/domain/entities/class_session.dart';

abstract class ClassSessionsRemoteDataSource {
  Future<List<ClassSession>> listSessions();

  Future<List<ClassCoachOption>> listCoaches();

  Future<ClassSession> upsertSession({
    String? id,
    required String title,
    required DateTime startsAt,
    required DateTime endsAt,
    required int capacity,
    String? coachEmployeeId,
    String status = 'scheduled',
  });
}

class ClassSessionsSupabaseRemoteDataSource
    implements ClassSessionsRemoteDataSource {
  ClassSessionsSupabaseRemoteDataSource({SupabaseClient? client})
    : _client = client;

  final SupabaseClient? _client;

  SupabaseClient? get _supabase {
    if (_client != null) return _client;
    if (!SupabaseConfig.isConfigured) return null;
    return Supabase.instance.client;
  }

  @override
  Future<List<ClassSession>> listSessions() async {
    final client = _requireClient();
    try {
      final rows = await client
          .from('class_sessions')
          .select(
            'id, tenant_id, title, starts_at, ends_at, capacity, '
            'coach_employee_id, status, created_at, updated_at',
          )
          .order('starts_at', ascending: true);
      return (rows as List<dynamic>)
          .map((row) => _mapSession(row as Map<String, dynamic>))
          .toList(growable: false);
    } on PostgrestException catch (e) {
      throw _mapException(e);
    } catch (e) {
      if (e is ClassSessionsFailure) rethrow;
      throw const ClassSessionsUnknownFailure();
    }
  }

  @override
  Future<List<ClassCoachOption>> listCoaches() async {
    final client = _requireClient();
    try {
      final rows = await client
          .from('employees')
          .select('id, name, role')
          .order('name');
      return (rows as List<dynamic>).map((row) {
        final map = row as Map<String, dynamic>;
        return ClassCoachOption(
          id: map['id'] as String,
          name: map['name'] as String,
          role: map['role'] as String? ?? '',
        );
      }).toList(growable: false);
    } on PostgrestException catch (e) {
      throw _mapException(e);
    } catch (e) {
      if (e is ClassSessionsFailure) rethrow;
      throw const ClassSessionsUnknownFailure();
    }
  }

  @override
  Future<ClassSession> upsertSession({
    String? id,
    required String title,
    required DateTime startsAt,
    required DateTime endsAt,
    required int capacity,
    String? coachEmployeeId,
    String status = 'scheduled',
  }) async {
    final client = _requireClient();
    try {
      final params = <String, dynamic>{
        'p_title': title.trim(),
        'p_starts_at': startsAt.toUtc().toIso8601String(),
        'p_ends_at': endsAt.toUtc().toIso8601String(),
        'p_capacity': capacity,
        'p_id': id,
        'p_coach_employee_id': coachEmployeeId,
        'p_status': status,
      };
      final result = await client.rpc('upsert_class_session', params: params);
      final map = Map<String, dynamic>.from(result as Map);
      return _mapSession(map);
    } on PostgrestException catch (e) {
      throw _mapException(e);
    } catch (e) {
      if (e is ClassSessionsFailure) rethrow;
      throw const ClassSessionsUnknownFailure();
    }
  }

  SupabaseClient _requireClient() {
    final client = _supabase;
    if (client == null) {
      throw const ClassSessionsNotConfiguredFailure();
    }
    return client;
  }

  ClassSession _mapSession(Map<String, dynamic> row) {
    return ClassSession(
      id: row['id'] as String,
      tenantId: row['tenant_id'] as String,
      title: row['title'] as String,
      startsAt: DateTime.parse(row['starts_at'] as String).toLocal(),
      endsAt: DateTime.parse(row['ends_at'] as String).toLocal(),
      capacity: (row['capacity'] as num).toInt(),
      coachEmployeeId: row['coach_employee_id'] as String?,
      status: row['status'] as String? ?? 'scheduled',
      createdAt: _parseOptionalDate(row['created_at']),
      updatedAt: _parseOptionalDate(row['updated_at']),
    );
  }

  DateTime? _parseOptionalDate(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value)?.toLocal();
  }

  ClassSessionsFailure _mapException(PostgrestException e) {
    final code = e.code ?? '';
    final message = e.message.toLowerCase();
    if (code == '42501' || message.contains('forbidden')) {
      return const ClassSessionsForbiddenFailure();
    }
    if (code == '22023' ||
        message.contains('invalid') ||
        message.contains('check')) {
      return const ClassSessionsValidationFailure();
    }
    return const ClassSessionsUnknownFailure();
  }
}
