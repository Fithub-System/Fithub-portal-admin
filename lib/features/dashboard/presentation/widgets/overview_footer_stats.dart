import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/kinetic_tokens.dart';
import '../fixtures/overview_stitch_fixtures.dart';

/// Stitch footer / Insights stats cluster (4 tiles) — Admin Overview.
///
/// FEAT-60: members + check-ins today bind live; guest stays fixture until
/// FEAT-62; incidents may remain fixture. Null prop → fixture for that tile.
class OverviewFooterStats extends StatelessWidget {
  const OverviewFooterStats({
    super.key,
    this.totalActive,
    this.checkInsToday,
    this.guestPasses,
    this.incidentReports,
    this.loading = false,
  });

  /// Live members count label; null → Stitch fixture `2,841`.
  final String? totalActive;

  /// Live check-ins today; null → legacy classes-today fixture `42`.
  final String? checkInsToday;

  /// Guest passes — leave null for FEAT-62 fixture chrome.
  final String? guestPasses;

  /// Incident reports — may stay fixture this FEAT.
  final String? incidentReports;

  final bool loading;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth >= 720 ? 4 : 2;
        final membersValue = loading
            ? '…'
            : (totalActive ?? OverviewStitchFixtures.totalActive);
        final checkInsValue = loading
            ? '…'
            : (checkInsToday ?? OverviewStitchFixtures.classesToday);
        final tiles = [
          _StatTile(
            key: const Key('overview-stat-members'),
            label: 'dashboard.stats.total_active'.tr(),
            value: membersValue,
          ),
          _StatTile(
            key: const Key('overview-stat-checkins'),
            label: 'dashboard.stats.check_ins_today'.tr(),
            value: checkInsValue,
          ),
          _StatTile(
            key: const Key('overview-stat-guests'),
            label: 'dashboard.stats.guest_passes'.tr(),
            value: guestPasses ?? OverviewStitchFixtures.guestPasses,
          ),
          _StatTile(
            key: const Key('overview-stat-incidents'),
            label: 'dashboard.stats.incidents'.tr(),
            value: incidentReports ?? OverviewStitchFixtures.incidentReports,
            muted: true,
          ),
        ];

        return GridView.count(
          key: const Key('overview-footer-stats'),
          crossAxisCount: cols,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: cols == 4 ? 2.4 : 2.2,
          children: tiles,
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    super.key,
    required this.label,
    required this.value,
    this.muted = false,
  });

  final String label;
  final String value;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsetsDirectional.all(24),
      decoration: BoxDecoration(
        color: KineticTokens.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF171717)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.start,
            style: textTheme.labelSmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
              color: KineticTokens.zincGray,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.start,
            style: textTheme.headlineSmall?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: muted
                  ? KineticTokens.zincGray.withValues(alpha: 0.85)
                  : KineticTokens.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
