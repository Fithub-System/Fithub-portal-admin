import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fithub_portal_admin/core/network/supabase_config.dart';
import 'package:fithub_portal_admin/features/add_member/domain/add_member_failure.dart';
import 'package:fithub_portal_admin/features/add_member/domain/entities/athlete_enroll_match.dart';
import 'package:fithub_portal_admin/features/add_member/domain/entities/enroll_gym_member_result.dart';

abstract class AddMemberRemoteDataSource {
  Future<AthleteEnrollMatch?> findAthleteForEnroll(String email);

  Future<EnrollGymMemberResult> enrollGymMember(String athleteId);
}

class AddMemberSupabaseRemoteDataSource implements AddMemberRemoteDataSource {
  AddMemberSupabaseRemoteDataSource({SupabaseClient? client})
    : _client = client;

  final SupabaseClient? _client;

  SupabaseClient? get _supabase {
    if (_client != null) return _client;
    if (!SupabaseConfig.isConfigured) return null;
    return Supabase.instance.client;
  }

  @override
  Future<AthleteEnrollMatch?> findAthleteForEnroll(String email) async {
    final client = _requireClient();
    try {
      final result = await client.rpc(
        'find_athlete_for_enroll',
        params: {'p_email': email.trim()},
      );
      if (result == null) return null;
      if (result is! Map) return null;
      final map = Map<String, dynamic>.from(result);
      final id = map['id'] as String?;
      if (id == null || id.isEmpty) return null;
      final fullName = (map['full_name'] as String?)?.trim();
      return AthleteEnrollMatch(
        id: id,
        fullName: (fullName == null || fullName.isEmpty) ? id : fullName,
      );
    } on PostgrestException catch (e) {
      throw _mapException(e);
    } catch (e) {
      if (e is AddMemberFailure) rethrow;
      throw const AddMemberUnknownFailure();
    }
  }

  @override
  Future<EnrollGymMemberResult> enrollGymMember(String athleteId) async {
    final client = _requireClient();
    try {
      final result = await client.rpc(
        'enroll_gym_member',
        params: {'p_athlete_id': athleteId},
      );
      if (result is! Map) {
        throw const AddMemberUnknownFailure();
      }
      final map = Map<String, dynamic>.from(result);
      final tenantId = map['tenant_id'] as String?;
      final enrolledAthleteId = map['athlete_id'] as String?;
      if (tenantId == null || enrolledAthleteId == null) {
        throw const AddMemberUnknownFailure();
      }
      return EnrollGymMemberResult(
        tenantId: tenantId,
        athleteId: enrolledAthleteId,
        created: map['created'] as bool? ?? false,
      );
    } on PostgrestException catch (e) {
      throw _mapException(e);
    } catch (e) {
      if (e is AddMemberFailure) rethrow;
      throw const AddMemberUnknownFailure();
    }
  }

  SupabaseClient _requireClient() {
    final client = _supabase;
    if (client == null) {
      throw const AddMemberNotConfiguredFailure();
    }
    return client;
  }

  AddMemberFailure _mapException(PostgrestException e) {
    final code = e.code ?? '';
    final message = e.message.toLowerCase();
    if (code == '42501' || message.contains('forbidden')) {
      return const AddMemberForbiddenFailure();
    }
    if (code == '22023' ||
        message.contains('athlete not found') ||
        message.contains('invalid_input')) {
      return const AddMemberNotFoundFailure();
    }
    return const AddMemberUnknownFailure();
  }
}
