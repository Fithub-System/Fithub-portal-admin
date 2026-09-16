import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fithub_portal_admin/core/network/postgrest_row.dart';
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
      return asJsonMapList(rows).map(_mapSession).toList(growable: false);
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
      return asJsonMapList(rows)
          .map((map) {
            return ClassCoachOption(
              id: jsonStringOrNull(map['id']) ?? '',
              name: jsonStringOrNull(map['name']) ?? '',
              role: jsonStringOrNull(map['role']) ?? '',
            );
          })
          .where((coach) => coach.id.isNotEmpty && coach.name.isNotEmpty)
          .toList(growable: false);
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
      final map = asJsonMap(result);
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
    final starts = parseJsonUtc(row['starts_at']) ?? DateTime.now().toUtc();
    final ends = parseJsonUtc(row['ends_at']) ?? starts;
    return ClassSession(
      id: jsonStringOrNull(row['id']) ?? '',
      tenantId: jsonStringOrNull(row['tenant_id']) ?? '',
      title: jsonStringOrNull(row['title']) ?? '',
      startsAt: starts.toLocal(),
      endsAt: ends.toLocal(),
      capacity: asJsonInt(row['capacity']),
      coachEmployeeId: jsonStringOrNull(row['coach_employee_id']),
      status: jsonStringOrNull(row['status']) ?? 'scheduled',
      createdAt: parseJsonUtc(row['created_at'])?.toLocal(),
      updatedAt: parseJsonUtc(row['updated_at'])?.toLocal(),
    );
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
