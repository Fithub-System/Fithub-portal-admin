import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/network/supabase_config.dart';
import '../../../domain/entities/member_roster_entry.dart';
import '../../../domain/member_roster_failure.dart';
import 'member_roster_remote_data_source.dart';

/// Supabase PostgREST adapter for tenant athlete roster (FEAT-01 §6.2).
///
/// Requires Backend `feature/backend-feat01-qr-member-roster` employee SELECT
/// policy on `public.athletes` — Portal does not invent RLS.
///
/// FEAT-07: also loads active `athlete_memberships` (+ plan name) for Drift cache.
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
      final athletes = list
          .map((row) => _mapRow(row as Map<String, dynamic>))
          .toList(growable: false);

      final membershipByAthlete = await _fetchActiveMemberships(client);
      if (membershipByAthlete.isEmpty) return athletes;

      return athletes
          .map((athlete) {
            final membership = membershipByAthlete[athlete.id];
            if (membership == null) return athlete;
            return athlete.copyWith(
              membershipStatus: membership.status,
              membershipPlanName: membership.planName,
              membershipEndsAt: membership.endsAt,
            );
          })
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

  Future<Map<String, _CachedMembership>> _fetchActiveMemberships(
    SupabaseClient client,
  ) async {
    try {
      final rows = await client
          .from('athlete_memberships')
          .select('athlete_id, status, ends_at, membership_plans(name)')
          .eq('status', 'active');

      final map = <String, _CachedMembership>{};
      for (final row in rows as List<dynamic>) {
        final data = row as Map<String, dynamic>;
        final athleteId = data['athlete_id'] as String?;
        if (athleteId == null) continue;
        final plan = data['membership_plans'];
        String? planName;
        if (plan is Map<String, dynamic>) {
          planName = plan['name'] as String?;
        }
        final endsRaw = data['ends_at'] as String?;
        map[athleteId] = _CachedMembership(
          status: data['status'] as String? ?? 'active',
          planName: planName,
          endsAt: endsRaw == null ? null : DateTime.parse(endsRaw).toUtc(),
        );
      }
      return map;
    } on PostgrestException {
      // Membership tables may lag behind roster; do not fail whole sync.
      return const {};
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

class _CachedMembership {
  const _CachedMembership({
    required this.status,
    required this.planName,
    required this.endsAt,
  });

  final String status;
  final String? planName;
  final DateTime? endsAt;
}
