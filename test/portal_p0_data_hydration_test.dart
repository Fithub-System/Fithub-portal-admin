import 'package:flutter_test/flutter_test.dart';
import 'package:fithub_portal_admin/core/network/postgrest_row.dart';
import 'package:fithub_portal_admin/features/access_scanner/data/data_sources/remote/member_roster_row_mapper.dart';
import 'package:fithub_portal_admin/features/dashboard/presentation/cubit/overview_metrics_cubit.dart';
import 'package:fithub_portal_admin/features/dashboard/domain/entities/overview_home_metrics.dart';
import 'package:fithub_portal_admin/features/dashboard/domain/repositories/overview_home_metrics_repository.dart';

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
      expect(mapped.cryptoSalt, '');
    });

    test('embeddedAthlete unwraps list payloads', () {
      final inner = embeddedAthlete([
        {'id': 'a1', 'full_name': 'Sam'},
      ]);
      final mapped = mapAthleteRosterRow(inner);
      expect(mapped?.id, 'a1');
    });

    test('mapAthleteRosterRow skips incomplete rows', () {
      expect(mapAthleteRosterRow(<String, dynamic>{'id': 'x'}), isNull);
      expect(mapAthleteRosterRow('not-a-map'), isNull);
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
}
