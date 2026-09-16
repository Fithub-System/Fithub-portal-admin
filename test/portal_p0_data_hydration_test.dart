import 'package:flutter_test/flutter_test.dart';
import 'package:fithub_portal_admin/core/network/postgrest_row.dart';
import 'package:fithub_portal_admin/features/access_scanner/data/data_sources/local/member_roster_local_data_source.dart';
import 'package:fithub_portal_admin/features/access_scanner/data/data_sources/remote/member_roster_remote_data_source.dart';
import 'package:fithub_portal_admin/features/access_scanner/data/data_sources/remote/member_roster_row_mapper.dart';
import 'package:fithub_portal_admin/features/access_scanner/data/repositories/member_roster_repository_impl.dart';
import 'package:fithub_portal_admin/features/access_scanner/domain/entities/member_roster_entry.dart';
import 'package:fithub_portal_admin/features/dashboard/presentation/cubit/overview_metrics_cubit.dart';
import 'package:fithub_portal_admin/features/dashboard/domain/entities/overview_home_metrics.dart';
import 'package:fithub_portal_admin/features/dashboard/domain/repositories/overview_home_metrics_repository.dart';
import 'package:fithub_portal_admin/features/memberships/data/data_sources/remote/memberships_remote_data_source.dart';

class _DegradedRepo implements OverviewHomeMetricsRepository {
  @override
  Future<OverviewHomeMetrics> load({required String tenantId}) async {
    return const OverviewHomeMetrics(
      membersCount: 3,
      checkInsToday: 0,
      revenueTodayCents: 0,
      revenueCurrency: 'EGP',
      expiringSoon: [],
      cloudDegraded: true,
    );
  }
}

void main() {
  group('P0 PostgREST web JSON mapping', () {
    test('asJsonMap accepts Map<dynamic, dynamic> from Flutter web', () {
      final raw = <dynamic, dynamic>{'amount_cents': 2500.0, 'currency': 'EGP'};
      final map = asJsonMap(raw);
      expect(asJsonInt(map['amount_cents']), 2500);
      expect(map['currency'], 'EGP');
    });

    test('mapAthleteRosterRow survives nullable salt and num score', () {
      final mapped = mapAthleteRosterRow(<dynamic, dynamic>{
        'id': 'athlete-1',
        'full_name': 'Ava Chen',
        'avatar_url': null,
        'power_score': 88.0,
        'crypto_salt': null,
        'created_at': '2026-09-15T08:00:00Z',
      });
      expect(mapped, isNotNull);
      expect(mapped!.id, 'athlete-1');
      expect(mapped.fullName, 'Ava Chen');
      expect(mapped.powerScore, 88);
      expect(mapped.cryptoSalt, '00');
    });

    test('embeddedAthlete unwraps list payloads', () {
      final inner = embeddedAthlete([
        {'id': 'a1', 'full_name': 'Sam'},
      ]);
      final mapped = mapAthleteRosterRow(inner);
      expect(mapped?.id, 'a1');
    });

    test('asJsonMapList and membershipPlanFromRow bind web JSON arrays', () {
      final rows = <dynamic>[
        <dynamic, dynamic>{
          'id': 'p1',
          'tenant_id': 't1',
          'name': 'Monthly',
          'duration_days': 30.0,
          'price_cents': 50000.0,
          'currency': 'EGP',
          'is_active': true,
          'pass_kind': 'single_branch',
        },
      ];
      expect(asJsonMapList(rows), hasLength(1));
      final plan = membershipPlanFromRow(rows.first);
      expect(plan?.name, 'Monthly');
      expect(plan?.durationDays, 30);
      expect(plan?.priceCents, 50000);
    });
  });

  group('P0 Overview degraded KPIs', () {
    test('cubit surfaces load_failed while keeping live counts', () async {
      final cubit = OverviewMetricsCubit(
        repository: _DegradedRepo(),
        tenantId: 't1',
      );
      await cubit.refresh();
      expect(cubit.state.status, OverviewMetricsStatus.failure);
      expect(cubit.state.statusMessageKey, 'dashboard.metrics.load_failed');
      expect(cubit.state.displayMetrics.membersCount, 3);
      await cubit.close();
    });
  });

  group('P0 roster Drift CHECK must not hide cloud 200', () {
    test('listCachedMembers returns live rows when upsert throws', () async {
      final repo = MemberRosterRepositoryImpl(
        remote: _OkRosterRemote(),
        local: _ThrowingRosterLocal(),
      );
      final count = await repo.syncRoster(tenantId: 't1');
      expect(count, 1);
      final listed = await repo.listCachedMembers(tenantId: 't1');
      expect(listed.single.fullName, 'Ava Chen');
      expect(listed.single.cryptoSalt, '00');
    });
  });
}

class _OkRosterRemote implements MemberRosterRemoteDataSource {
  @override
  Future<List<MemberRosterEntry>> fetchAthletes() async {
    return [
      mapAthleteRosterRow(<dynamic, dynamic>{
            'id': 'athlete-1',
            'full_name': 'Ava Chen',
            'crypto_salt': null,
            'power_score': 10,
            'created_at': '2026-09-15T08:00:00Z',
          }) ??
          (throw StateError('mapper')),
    ];
  }
}

class _ThrowingRosterLocal implements MemberRosterLocalDataSource {
  @override
  Future<void> upsertMembers({
    required String tenantId,
    required List<MemberRosterEntry> members,
  }) async {
    throw Exception('Drift CHECK crypto_salt');
  }

  @override
  Future<int> countCachedMembers({required String tenantId}) async => 0;

  @override
  Future<List<MemberRosterEntry>> listCachedMembers({
    required String tenantId,
  }) async => [];
}
