import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/network/supabase_config.dart';
import '../../../domain/entities/member_roster_entry.dart';
import '../../../domain/member_roster_failure.dart';
import 'member_roster_remote_data_source.dart';

/// Supabase PostgREST adapter for tenant athlete roster (FEAT-01 §6.2).
///
/// Requires Backend `feature/backend-feat01-qr-member-roster` employee SELECT
/// policy on `public.athletes` — Portal does not invent RLS.
class MemberRosterSupabaseRemoteDataSource
    implements MemberRosterRemoteDataSource {
  MemberRosterSupabaseRemoteDataSource({SupabaseClient? client})
    : _client = client;

  final SupabaseClient? _client;

  SupabaseClient? get _supabase {
    if (_client != null) return _client;
    if (!SupabaseConfig.isConfigured) return null;
    return Supabase.instance.client;
  }

  @override
  Future<List<MemberRosterEntry>> fetchAthletes() async {
    final client = _supabase;
    if (client == null) {
      throw const MemberRosterNotConfiguredFailure();
    }

    try {
      final rows = await client
          .from('athletes')
          .select(
            'id, full_name, avatar_url, power_score, crypto_salt, created_at',
          );

      final list = rows as List<dynamic>;
      return list
          .map((row) => _mapRow(row as Map<String, dynamic>))
          .toList(growable: false);
    } on PostgrestException catch (error) {
      if (_isPolicyDenial(error)) {
        throw const MemberRosterPolicyFailure();
      }
      throw const MemberRosterUnknownFailure();
    } catch (error) {
      if (error is MemberRosterFailure) rethrow;
      throw const MemberRosterUnknownFailure();
    }
  }

  MemberRosterEntry _mapRow(Map<String, dynamic> row) {
    return MemberRosterEntry(
      id: row['id'] as String,
      fullName: row['full_name'] as String,
      avatarUrl: row['avatar_url'] as String?,
      powerScore: (row['power_score'] as num?)?.toInt() ?? 100,
      cryptoSalt: row['crypto_salt'] as String,
      createdAt: DateTime.parse(row['created_at'] as String).toUtc(),
    );
  }

  bool _isPolicyDenial(PostgrestException error) {
    final code = error.code ?? '';
    return code == '42501' ||
        code == 'PGRST301' ||
        error.message.toLowerCase().contains('policy');
  }
}
