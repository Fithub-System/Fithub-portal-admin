import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/network/supabase_config.dart';
import '../../../domain/entities/pending_attendance.dart';
import '../../../domain/offline_sync_failure.dart';
import 'offline_sync_remote_data_source.dart';

/// Supabase PostgREST adapter — bulk upsert `attendance_logs` + gyms UPDATE.
class OfflineSyncSupabaseRemoteDataSource
    implements OfflineSyncRemoteDataSource {
  OfflineSyncSupabaseRemoteDataSource({SupabaseClient? client})
    : _client = client;

  final SupabaseClient? _client;

  SupabaseClient? get _supabase {
    if (_client != null) return _client;
    if (!SupabaseConfig.isConfigured) return null;
    return Supabase.instance.client;
  }

  @override
  Future<void> upsertAttendanceLogs(List<PendingAttendance> rows) async {
    final client = _supabase;
    if (client == null) {
      throw const OfflineSyncNotConfiguredFailure();
    }
    if (rows.isEmpty) return;

    final payload = rows
        .map(
          (row) => <String, dynamic>{
            'id': row.id,
            'tenant_id': row.tenantId,
            'athlete_id': row.athleteId,
            'checked_in_at': row.checkedInAt.toUtc().toIso8601String(),
            'is_synced': true,
          },
        )
        .toList(growable: false);

    try {
      // Single PostgREST upsert = one SQL statement; conflict on PK → idempotent.
      await client.from('attendance_logs').upsert(payload, onConflict: 'id');
    } on PostgrestException catch (error) {
      // Same-day unique (23505): cloud already has a check-in for that
      // athlete/tenant/UTC day — treat as idempotent success (caller marks synced).
      if (_isUniqueViolation(error)) {
        return;
      }
      throw OfflineSyncAttendanceUpsertFailure(_mapUpsertMessage(error));
    } catch (_) {
      throw const OfflineSyncAttendanceUpsertFailure();
    }
  }

  @override
  Future<void> updateGymOccupancy({
    required String tenantId,
    required int currentOccupancy,
  }) async {
    final client = _supabase;
    if (client == null) {
      throw const OfflineSyncNotConfiguredFailure();
    }

    try {
      await client
          .from('gyms')
          .update({'current_occupancy': currentOccupancy})
          .eq('id', tenantId);
    } on PostgrestException catch (error) {
      if (_isPermissionOrRls(error)) {
        throw OfflineSyncOccupancyRlsFailure(_mapOccupancyDenial(error));
      }
      throw OfflineSyncUnknownFailure(error.message);
    } catch (error) {
      if (error is OfflineSyncFailure) rethrow;
      throw const OfflineSyncUnknownFailure();
    }
  }

  String _mapUpsertMessage(PostgrestException error) {
    if (_isPermissionOrRls(error)) {
      // Likely missing GRANT INSERT on attendance_logs — Backend must ship.
      return 'connectivity.sync.error.attendance_grant;'
          '${error.code ?? ''};${error.message}';
    }
    return 'connectivity.sync.error.upsert_failed;${error.message}';
  }

  String _mapOccupancyDenial(PostgrestException error) {
    return 'connectivity.sync.error.occupancy_rls;'
        '${error.code ?? ''};${error.message}';
  }

  bool _isPermissionOrRls(PostgrestException error) {
    final code = error.code ?? '';
    final message = error.message.toLowerCase();
    return code == '42501' ||
        code == 'PGRST301' ||
        message.contains('permission denied') ||
        message.contains('row-level security') ||
        message.contains('rls') ||
        message.contains('new row violates');
  }

  /// Postgres unique_violation — same-day attendance index or PK race.
  bool _isUniqueViolation(PostgrestException error) {
    final code = error.code ?? '';
    final message = error.message.toLowerCase();
    final details = (error.details?.toString() ?? '').toLowerCase();
    return code == '23505' ||
        message.contains('duplicate key') ||
        message.contains('unique constraint') ||
        details.contains('attendance_logs_one_per_athlete_tenant_utc_day');
  }
}
