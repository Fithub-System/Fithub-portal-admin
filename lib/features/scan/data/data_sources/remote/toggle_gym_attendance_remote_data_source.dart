import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fithub_portal_admin/core/network/supabase_config.dart';

/// Result of RPC `toggle_gym_attendance` (FEAT-92).
class GymAttendanceToggleResult {
  const GymAttendanceToggleResult({
    required this.visitId,
    required this.event,
    required this.occupancy,
    required this.capacityLimit,
    this.memberName,
    this.membershipStatus,
  });

  final String visitId;

  /// `CHECK_IN` or `CHECK_OUT`.
  final String event;
  final int occupancy;
  final int capacityLimit;
  final String? memberName;
  final String? membershipStatus;

  bool get isCheckOut => event == 'CHECK_OUT';
}

class GymAttendanceToggleFailure implements Exception {
  const GymAttendanceToggleFailure(this.code, {this.message});

  final String code;
  final String? message;

  @override
  String toString() => message ?? code;
}

/// Employee JWT → `toggle_gym_attendance(p_athlete_id)`.
abstract class ToggleGymAttendanceRemoteDataSource {
  Future<GymAttendanceToggleResult> toggle(String athleteId);
}

class ToggleGymAttendanceSupabaseRemoteDataSource
    implements ToggleGymAttendanceRemoteDataSource {
  ToggleGymAttendanceSupabaseRemoteDataSource({SupabaseClient? client})
    : _client = client;

  final SupabaseClient? _client;

  SupabaseClient? get _supabase {
    if (_client != null) return _client;
    if (!SupabaseConfig.isConfigured) return null;
    return Supabase.instance.client;
  }

  @override
  Future<GymAttendanceToggleResult> toggle(String athleteId) async {
    final client = _supabase;
    if (client == null) {
      throw const GymAttendanceToggleFailure('not_configured');
    }
    try {
      final raw = await client.rpc(
        'toggle_gym_attendance',
        params: {'p_athlete_id': athleteId},
      );
      final data = _asMap(raw);
      final visitId = data['visit_id']?.toString() ?? '';
      final event = data['event']?.toString() ?? 'CHECK_IN';
      if (visitId.isEmpty) {
        throw const GymAttendanceToggleFailure(
          'malformed',
          message: 'missing_visit_id',
        );
      }
      return GymAttendanceToggleResult(
        visitId: visitId,
        event: event,
        occupancy: _asInt(data['occupancy']),
        capacityLimit: _asInt(data['capacity_limit']),
        memberName: data['member_name']?.toString(),
        membershipStatus: data['membership_status']?.toString(),
      );
    } on GymAttendanceToggleFailure {
      rethrow;
    } on PostgrestException catch (e) {
      throw GymAttendanceToggleFailure(_mapCode(e), message: e.message);
    } catch (e) {
      if (e is GymAttendanceToggleFailure) rethrow;
      throw const GymAttendanceToggleFailure('unknown');
    }
  }

  Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return const {};
  }

  int _asInt(dynamic raw) {
    if (raw is int) return raw;
    return int.tryParse(raw?.toString() ?? '') ?? 0;
  }

  String _mapCode(PostgrestException e) {
    final hay = '${e.message} ${e.code} ${e.details}'.toLowerCase();
    if (hay.contains('capacity') || hay.contains('full')) {
      return 'at_capacity';
    }
    if (hay.contains('42501') || hay.contains('forbidden')) {
      return 'forbidden';
    }
    return 'unknown';
  }
}
