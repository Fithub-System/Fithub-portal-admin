import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/kinetic_tokens.dart';

/// Stitch Daily Yield card (`#C3F400`) — Admin Overview hero col-span-5.
///
/// Revenue stream has no FEAT-16 Backend contract; amount shows em-dash
/// placeholder while layout matches Visual Spec Card.
class DailyYieldCard extends StatelessWidget {
  const DailyYieldCard({super.key, this.amountLabel});

  /// Live amount when bound; null → placeholder.
  final String? amountLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final amount = amountLabel ?? 'home.shell.em_dash'.tr();

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
                    'dashboard.yield.delta_placeholder'.tr(),
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
