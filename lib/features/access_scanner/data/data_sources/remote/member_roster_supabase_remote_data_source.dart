import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/network/postgrest_row.dart';
import '../../../../../core/network/supabase_config.dart';
import '../../../domain/entities/member_roster_entry.dart';
import '../../../domain/member_roster_failure.dart';
import 'member_roster_remote_data_source.dart';
import 'member_roster_row_mapper.dart';

/// Supabase PostgREST adapter for tenant athlete roster (FEAT-01 §6.2).
///
/// Requires Backend `feature/backend-feat01-qr-member-roster` employee SELECT
/// policy on `public.athletes` — Portal does not invent RLS.
///
/// Primary read is `gym_members ⨝ athletes` (same join RLS uses). Direct
/// `athletes` SELECT is a fallback when the embed is unavailable.
///
/// FEAT-07 / FEAT-61: loads operable memberships (+ plan name / ids) for Drift.
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
      final athletes =
          await _fetchViaGymMembers(client) ??
          await _fetchAthletesDirect(client);

      var membershipByAthlete = const <String, _CachedMembership>{};
      try {
        membershipByAthlete = await _fetchOperableMemberships(client);
      } catch (_) {
        // Roster rows must still bind when membership overlay mapping fails.
      }
      if (membershipByAthlete.isEmpty) return athletes;

      return athletes
          .map((athlete) {
            final membership = membershipByAthlete[athlete.id];
            if (membership == null) return athlete;
            return athlete.copyWith(
              membershipId: membership.id,
              membershipPlanId: membership.planId,
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

  /// Tenant-scoped enrollments. RLS already filters `gym_members` to the
  /// caller gym; `!inner` drops orphan membership rows.
  Future<List<MemberRosterEntry>?> _fetchViaGymMembers(
    SupabaseClient client,
  ) async {
    try {
      final rows = asJsonMapList(
        await client
            .from('gym_members')
            .select(
              'athlete_id, athletes!inner(id, full_name, avatar_url, power_score, crypto_salt, created_at)',
            ),
      );

      final athletes = <MemberRosterEntry>[];
      for (final data in rows) {
        final mapped = mapAthleteRosterRow(embeddedAthlete(data['athletes']));
        if (mapped != null) athletes.add(mapped);
      }
      // Mapped-empty with source rows means the embed did not bind — fall
      // through to `athletes` SELECT (same 200 payload the Network tab shows).
      if (athletes.isEmpty && rows.isNotEmpty) return null;
      return athletes;
    } on PostgrestException catch (error) {
      if (_isPolicyDenial(error)) {
        throw const MemberRosterPolicyFailure();
      }
      return null;
    } catch (error) {
      if (error is MemberRosterFailure) rethrow;
      return null;
    }
  }

  Future<List<MemberRosterEntry>> _fetchAthletesDirect(
    SupabaseClient client,
  ) async {
    final rows = asJsonMapList(
      await client
          .from('athletes')
          .select(
            'id, full_name, avatar_url, power_score, crypto_salt, created_at',
          ),
    );

    final athletes = <MemberRosterEntry>[];
    for (final row in rows) {
      final mapped = mapAthleteRosterRow(row);
      if (mapped != null) athletes.add(mapped);
    }
    return athletes;
  }

  /// Prefer active, then paused, then scheduled (one row per athlete).
  Future<Map<String, _CachedMembership>> _fetchOperableMemberships(
    SupabaseClient client,
  ) async {
    try {
      final rows = await client
          .from('athlete_memberships')
          .select(
            'id, athlete_id, plan_id, status, ends_at, membership_plans(name)',
          )
          .inFilter('status', ['active', 'paused', 'scheduled']);

      final map = <String, _CachedMembership>{};
      for (final data in asJsonMapList(rows)) {
        final athleteId = data['athlete_id']?.toString();
        final membershipId = data['id']?.toString();
        if (athleteId == null ||
            athleteId.isEmpty ||
            membershipId == null ||
            membershipId.isEmpty) {
          continue;
        }

        final plan = data['membership_plans'];
        String? planName;
        if (plan is Map) {
          planName = asJsonMap(plan)['name']?.toString();
        }

        final candidate = _CachedMembership(
          id: membershipId,
          planId: data['plan_id']?.toString(),
          status: data['status']?.toString() ?? 'active',
          planName: planName,
          endsAt: parseJsonUtc(data['ends_at']),
        );

        final existing = map[athleteId];
        if (existing == null ||
            _statusRank(candidate.status) < _statusRank(existing.status)) {
          map[athleteId] = candidate;
        }
      }
      return map;
    } on PostgrestException {
      // Membership tables may lag behind roster; do not fail whole sync.
      return const {};
    }
  }

  int _statusRank(String status) {
    switch (status) {
      case 'active':
        return 0;
      case 'paused':
        return 1;
      case 'scheduled':
        return 2;
      default:
        return 99;
    }
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
    required this.id,
    required this.planId,
    required this.status,
    required this.planName,
    required this.endsAt,
  });

  final String id;
  final String? planId;
  final String status;
  final String? planName;
  final DateTime? endsAt;
}
