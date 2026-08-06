import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/kinetic_tokens.dart';
import '../fixtures/overview_stitch_fixtures.dart';

/// Stitch footer stats cluster (4 tiles) — Admin Overview.
///
/// §4.1: ships artboard fixture counts when analytics unbound.
class OverviewFooterStats extends StatelessWidget {
  const OverviewFooterStats({
    super.key,
    this.totalActive,
    this.classesToday,
    this.guestPasses,
    this.incidentReports,
  });

  final String? totalActive;
  final String? classesToday;
  final String? guestPasses;
  final String? incidentReports;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth >= 720 ? 4 : 2;
        final tiles = [
          _StatTile(
            label: 'dashboard.stats.total_active'.tr(),
            value: totalActive ?? OverviewStitchFixtures.totalActive,
          ),
          _StatTile(
            label: 'dashboard.stats.classes_today'.tr(),
            value: classesToday ?? OverviewStitchFixtures.classesToday,
          ),
          _StatTile(
            label: 'dashboard.stats.guest_passes'.tr(),
            value: guestPasses ?? OverviewStitchFixtures.guestPasses,
          ),
          _StatTile(
            label: 'dashboard.stats.incidents'.tr(),
            value: incidentReports ?? OverviewStitchFixtures.incidentReports,
            muted: true,
          ),
        ];

        return GridView.count(
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
