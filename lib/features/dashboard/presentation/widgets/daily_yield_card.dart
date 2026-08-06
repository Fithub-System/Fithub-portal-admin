import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/kinetic_tokens.dart';
import '../fixtures/overview_stitch_fixtures.dart';

/// Stitch Daily Yield card (`#C3F400`) — Admin Overview hero col-span-5.
///
/// §4.1: ships Stitch sample amount/delta when unbound (`fixture`). Live
/// amount replaces the fixture when Backend binds — same chrome.
class DailyYieldCard extends StatelessWidget {
  const DailyYieldCard({super.key, this.amountLabel, this.deltaLabel});

  /// Live amount when bound; null → Stitch fixture `$12,482`.
  final String? amountLabel;

  /// Live delta when bound; null → Stitch fixture `+14.2% vs yesterday`.
  final String? deltaLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final amount = amountLabel ?? OverviewStitchFixtures.yieldAmount;
    final delta = deltaLabel ?? OverviewStitchFixtures.yieldDelta;

    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.all(32),
      decoration: BoxDecoration(
        color: KineticTokens.primaryContainer,
        borderRadius: BorderRadius.circular(KineticTokens.dashboardCardRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          PositionedDirectional(
            end: -24,
            bottom: -24,
            child: Icon(
              Icons.monetization_on_outlined,
              size: 192,
              color: KineticTokens.onPrimaryContainer.withValues(alpha: 0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'dashboard.yield.title'.tr(),
                textAlign: TextAlign.start,
                maxLines: 2,
                style: textTheme.headlineMedium?.copyWith(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  letterSpacing: -0.8,
                  height: 1.0,
                  color: KineticTokens.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'dashboard.yield.subtitle'.tr(),
                textAlign: TextAlign.start,
                style: textTheme.labelSmall?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.2,
                  color: KineticTokens.onPrimaryContainer.withValues(
                    alpha: 0.6,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Text(
                amount,
                textAlign: TextAlign.start,
                style: textTheme.displaySmall?.copyWith(
                  fontSize: 60,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                  height: 1,
                  color: KineticTokens.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    size: 16,
                    color: KineticTokens.onPrimaryContainer,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    delta,
                    style: textTheme.labelMedium?.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: KineticTokens.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
