import 'package:intl/intl.dart';

import '../../../access_scanner/domain/entities/member_roster_entry.dart';
import '../../../access_scanner/domain/repositories/member_roster_repository.dart';
import '../../../access_scanner/domain/use_cases/sync_member_roster_use_case.dart';
import '../../domain/entities/overview_expiring_row.dart';
import '../../domain/entities/overview_home_metrics.dart';
import '../../domain/repositories/overview_home_metrics_repository.dart';
import '../datasources/overview_metrics_remote_data_source.dart';

/// Composes roster (FEAT-59) + attendance count + paid charges sum (FEAT-60).
class OverviewHomeMetricsRepositoryImpl
    implements OverviewHomeMetricsRepository {
  OverviewHomeMetricsRepositoryImpl({
    required MemberRosterRepository memberRosterRepository,
    required OverviewMetricsRemoteDataSource remote,
    SyncMemberRosterUseCase? syncRoster,
    bool Function()? isOnline,
    DateTime Function()? clock,
  }) : _roster = memberRosterRepository,
       _remote = remote,
       _syncRoster = syncRoster,
       _isOnline = isOnline ?? (() => true),
       _clock = clock ?? DateTime.now;

  final MemberRosterRepository _roster;
  final OverviewMetricsRemoteDataSource _remote;
  final SyncMemberRosterUseCase? _syncRoster;
  final bool Function() _isOnline;
  final DateTime Function() _clock;

  @override
  Future<OverviewHomeMetrics> load({required String tenantId}) async {
    final sync = _syncRoster;
    if (sync != null && _isOnline()) {
      try {
        await sync(tenantId: tenantId);
      } catch (_) {
        // Still attempt cache + cloud KPI reads below.
      }
    }

    final members = await _roster.listCachedMembers(tenantId: tenantId);
    final now = _clock().toUtc();
    final dayStart = DateTime.utc(now.year, now.month, now.day);
    final windowEnd = now.add(OverviewHomeMetrics.expiringSoonWindow);

    final checkIns = await _remote.countCheckInsSince(
      tenantId: tenantId,
      dayStartUtc: dayStart,
    );
    final paid = await _remote.sumPaidChargesSince(
      tenantId: tenantId,
      dayStartUtc: dayStart,
    );

    return OverviewHomeMetrics(
      membersCount: members.length,
      checkInsToday: checkIns,
      revenueTodayCents: paid.totalCents,
      revenueCurrency: paid.currency.isEmpty
          ? OverviewHomeMetrics.defaultCurrency
          : paid.currency,
      expiringSoon: _mapExpiring(
        members: members,
        now: now,
        windowEnd: windowEnd,
      ),
    );
  }

  List<OverviewExpiringRow> _mapExpiring({
    required List<MemberRosterEntry> members,
    required DateTime now,
    required DateTime windowEnd,
  }) {
    final dateFmt = DateFormat.yMMMd();
    final rows = <OverviewExpiringRow>[];

    for (final member in members) {
      final ends = member.membershipEndsAt?.toUtc();
      if (ends == null) continue;
      final status = member.membershipStatus?.toLowerCase();
      if (status != null && status != 'active') continue;
      if (ends.isBefore(now) || ends.isAfter(windowEnd)) continue;

      final hoursLeft = ends.difference(now).inHours;
      final urgent = hoursLeft <= 24;
      rows.add(
        OverviewExpiringRow(
          fullName: member.fullName,
          email: '—',
          planLabel: (member.membershipPlanName ?? '—').toUpperCase(),
          expirationDate: dateFmt.format(ends.toLocal()),
          relativeLabel: _relativeLabel(hoursLeft),
          urgent: urgent,
        ),
      );
    }

    rows.sort((a, b) {
      if (a.urgent != b.urgent) return a.urgent ? -1 : 1;
      return a.expirationDate.compareTo(b.expirationDate);
    });
    return rows;
  }

  static String _relativeLabel(int hoursLeft) {
    if (hoursLeft <= 0) return 'Soon';
    if (hoursLeft < 24) return 'Today';
    if (hoursLeft < 48) return 'Tomorrow';
    return 'In 2 days';
  }
}
