import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/kinetic_tokens.dart';
import '../../domain/entities/overview_expiring_row.dart';
import 'access_gate_panel.dart';
import 'daily_yield_card.dart';
import 'expiring_memberships_card.dart';
import 'live_occupancy_gauge.dart';
import 'overview_footer_stats.dart';

/// FEAT-16 VF1 / VF1-R + FEAT-60 — Stitch Admin Overview Dashboard composition.
///
/// Screen `216e0407184f4c39bd501ed436c1e88b`. Owner layout delta (FEAT-60):
/// Hero (Occupancy|Revenue) → Insights/footer stats → Mid (Expiring|Gate).
///
/// Live KPIs when [liveMetricsBound]: revenue, expiring 48h, members, check-ins.
/// Guest Insights tile stays fixture (optional `member_invite_counts` bind
/// deferred — do not invent guest analytics).
class AdminOverviewDashboard extends StatelessWidget {
  const AdminOverviewDashboard({
    super.key,
    required this.currentOccupancy,
    required this.capacityLimit,
    required this.onOpenScanner,
    this.statusMessageKey,
    this.lastScanMemberName,
    this.lastScanApproved = false,
    this.lastScanRejectReason,
    this.liveMetricsBound = false,
    this.metricsLoading = false,
    this.revenueAmountLabel,
    this.expiringRows,
    this.membersCountLabel,
    this.checkInsTodayLabel,
  });

  final int currentOccupancy;
  final int capacityLimit;
  final VoidCallback onOpenScanner;
  final String? statusMessageKey;
  final String? lastScanMemberName;
  final bool lastScanApproved;
  final String? lastScanRejectReason;

  /// When true, cards bind live/empty honesty (no Stitch sample KPI masks).
  final bool liveMetricsBound;

  final bool metricsLoading;

  /// Formatted revenue for Daily Yield (e.g. `EGP 0`).
  final String? revenueAmountLabel;

  /// Live expiring rows; empty list + [liveMetricsBound] → empty chrome.
  final List<OverviewExpiringRow>? expiringRows;

  final String? membersCountLabel;
  final String? checkInsTodayLabel;

  static const String stitchScreenId =
      KineticTokens.stitchOccupancyScreenId;

  /// Breakpoint where hero becomes 7/5 and mid becomes 8/4 (≈ Tailwind lg).
  static const double wideBreakpoint = 1024;

  /// Semantic keys for layout-order tests (FEAT-60 AC-B1 / AC-C3).
  static const Key heroRowKey = Key('overview-hero-row');
  static const Key insightsRowKey = Key('overview-insights-row');
  static const Key midRowKey = Key('overview-mid-row');

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= wideBreakpoint;
        return SingleChildScrollView(
          padding: const EdgeInsetsDirectional.all(40),
          child: Column(
            key: const Key('overview-dashboard-column'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (statusMessageKey != null) ...[
                Text(
                  statusMessageKey!.tr(),
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: KineticTokens.electricLime,
                      ),
                ),
                const SizedBox(height: 16),
              ],
              // FEAT-60 owner order: Hero → Insights → Mid (Expiring|Gate)
              _HeroRow(
                key: heroRowKey,
                wide: wide,
                currentOccupancy: currentOccupancy,
                capacityLimit: capacityLimit,
                liveMetricsBound: liveMetricsBound,
                metricsLoading: metricsLoading,
                revenueAmountLabel: revenueAmountLabel,
              ),
              const SizedBox(height: 40),
              KeyedSubtree(
                key: insightsRowKey,
                child: OverviewFooterStats(
                  totalActive: liveMetricsBound ? membersCountLabel : null,
                  checkInsToday: liveMetricsBound ? checkInsTodayLabel : null,
                  // Guest + incidents: fixture (invite counts bind optional)
                  loading: metricsLoading && liveMetricsBound,
                ),
              ),
              const SizedBox(height: 40),
              _MidRow(
                key: midRowKey,
                wide: wide,
                onOpenScanner: onOpenScanner,
                lastScanApproved: lastScanApproved,
                lastScanMemberName: lastScanMemberName,
                lastScanRejectReason: lastScanRejectReason,
                liveMetricsBound: liveMetricsBound,
                metricsLoading: metricsLoading,
                expiringRows: expiringRows,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroRow extends StatelessWidget {
  const _HeroRow({
    super.key,
    required this.wide,
    required this.currentOccupancy,
    required this.capacityLimit,
    required this.liveMetricsBound,
    required this.metricsLoading,
    this.revenueAmountLabel,
  });

  final bool wide;
  final int currentOccupancy;
  final int capacityLimit;
  final bool liveMetricsBound;
  final bool metricsLoading;
  final String? revenueAmountLabel;

  @override
  Widget build(BuildContext context) {
    final occupancy = LiveOccupancyGauge(
      current: currentOccupancy,
      capacity: capacityLimit,
    );
    final yield = DailyYieldCard(
      amountLabel: liveMetricsBound ? (revenueAmountLabel ?? 'EGP 0') : null,
      // Omit fake % when yesterday unavailable (FEAT-60 honesty).
      deltaLabel: liveMetricsBound ? '' : null,
      loading: metricsLoading && liveMetricsBound,
    );

    if (!wide) {
      return Column(
        children: [
          occupancy,
          const SizedBox(height: 32),
          yield,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 7, child: occupancy),
        const SizedBox(width: 32),
        Expanded(flex: 5, child: yield),
      ],
    );
  }
}

class _MidRow extends StatelessWidget {
  const _MidRow({
    super.key,
    required this.wide,
    required this.onOpenScanner,
    required this.lastScanApproved,
    required this.liveMetricsBound,
    required this.metricsLoading,
    this.lastScanMemberName,
    this.lastScanRejectReason,
    this.expiringRows,
  });

  final bool wide;
  final VoidCallback onOpenScanner;
  final bool lastScanApproved;
  final String? lastScanMemberName;
  final String? lastScanRejectReason;
  final bool liveMetricsBound;
  final bool metricsLoading;
  final List<OverviewExpiringRow>? expiringRows;

  @override
  Widget build(BuildContext context) {
    final memberships = ExpiringMembershipsCard(
      rows: liveMetricsBound ? (expiringRows ?? const []) : null,
      liveBound: liveMetricsBound,
      loading: metricsLoading && liveMetricsBound,
    );
    final gate = AccessGatePanel(
      onOpenScanner: onOpenScanner,
      lastScanApproved: lastScanApproved,
      lastScanMemberName: lastScanMemberName,
      lastScanRejectReason: lastScanRejectReason,
    );

    if (!wide) {
      return Column(
        children: [
          memberships,
          const SizedBox(height: 32),
          gate,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 8, child: memberships),
        const SizedBox(width: 32),
        Expanded(flex: 4, child: gate),
      ],
    );
  }
}
