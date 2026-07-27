import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/kinetic_tokens.dart';

/// Stitch **Admin Overview Dashboard** Live Occupancy gauge.
///
/// Screen id: `216e0407184f4c39bd501ed436c1e88b`
/// Project: `13435235862240753621`
///
/// Layout (from exported HTML): left cyber-blue border card, italic black
/// headline, `current/capacity` in secondary-container blue, bar backdrop,
/// gradient progress track `#4A8EFF` → `#007BFF`.
class LiveOccupancyGauge extends StatelessWidget {
  const LiveOccupancyGauge({
    super.key,
    required this.current,
    required this.capacity,
  });

  final int current;
  final int capacity;

  static const _barHeights = <double>[
    0.20,
    0.35,
    0.55,
    0.45,
    0.80,
    0.90,
    0.85,
    0.70,
    0.60,
    0.40,
    0.30,
    0.25,
  ];

  @override
  Widget build(BuildContext context) {
    final progress = capacity == 0 ? 0.0 : (current / capacity).clamp(0.0, 1.0);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.all(32),
      decoration: BoxDecoration(
        color: KineticTokens.surfaceContainerLow,
        borderRadius: BorderRadius.circular(KineticTokens.dashboardCardRadius),
        border: const BorderDirectional(
          start: BorderSide(
            color: KineticTokens.secondaryContainer,
            width: KineticTokens.occupancyCardAccentWidth,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'dashboard.occupancy.live_label'.tr(),
                      textAlign: TextAlign.start,
                      style: textTheme.headlineMedium?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        letterSpacing: -0.8,
                        color: KineticTokens.onSurface,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'dashboard.occupancy.subtitle'.tr(),
                      textAlign: TextAlign.start,
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.2,
                        color: KineticTokens.secondaryFixedDim,
                      ),
                    ),
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$current',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: KineticTokens.secondaryContainer,
                        height: 1,
                      ),
                    ),
                    TextSpan(
                      text: '/$capacity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: KineticTokens.zincGray.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.end,
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 192,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.2,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (final h in _barHeights)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2,
                              ),
                              child: FractionallySizedBox(
                                heightFactor: h,
                                alignment: Alignment.bottomCenter,
                                child: const ColoredBox(
                                  color: KineticTokens.secondaryContainer,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: SizedBox(
                        height: KineticTokens.occupancyProgressHeight,
                        width: double.infinity,
                        child: Stack(
                          children: [
                            const ColoredBox(
                              color: KineticTokens.neutralTrack,
                              child: SizedBox.expand(),
                            ),
                            FractionallySizedBox(
                              widthFactor: progress,
                              alignment: AlignmentDirectional.centerStart,
                              child: const DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      KineticTokens.secondaryContainer,
                                      KineticTokens.cyberBlue,
                                    ],
                                  ),
                                ),
                                child: SizedBox.expand(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'dashboard.occupancy.timeline_start'.tr(),
                          style: _timelineStyle(textTheme),
                        ),
                        Text(
                          'dashboard.occupancy.timeline_peak'.tr(),
                          style: _timelineStyle(textTheme),
                        ),
                        Text(
                          'dashboard.occupancy.timeline_end'.tr(),
                          style: _timelineStyle(textTheme),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextStyle? _timelineStyle(TextTheme textTheme) {
    return textTheme.labelSmall?.copyWith(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.6,
      color: KineticTokens.zincGray,
    );
  }
}
