import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/kinetic_tokens.dart';

class PayoutKpiStrip extends StatelessWidget {
  const PayoutKpiStrip({
    super.key,
    required this.pending,
    required this.paidToday,
    required this.rejectedToday,
  });

  final int pending;
  final int paidToday;
  final int rejectedToday;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final tiles = [
          _KpiTile(
            label: 'payouts.kpi.pending'.tr(),
            value: '$pending',
            accent: KineticTokens.electricLime,
          ),
          _KpiTile(
            label: 'payouts.kpi.paid_today'.tr(),
            value: '$paidToday',
            accent: KineticTokens.secondaryContainer,
          ),
          _KpiTile(
            label: 'payouts.kpi.rejected_today'.tr(),
            value: '$rejectedToday',
            accent: KineticTokens.peakCoral,
          ),
        ];

        if (wide) {
          return Row(
            children: [
              for (var i = 0; i < tiles.length; i++) ...[
                if (i > 0) const SizedBox(width: 16),
                Expanded(child: tiles[i]),
              ],
            ],
          );
        }

        return Column(
          children: [
            for (var i = 0; i < tiles.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              tiles[i],
            ],
          ],
        );
      },
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: KineticTokens.surfaceContainerLow,
        borderRadius: BorderRadius.circular(KineticTokens.dashboardCardRadius),
        border: Border(
          left: BorderSide(color: accent, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Lexend',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: KineticTokens.zincGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Lexend',
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: accent,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
