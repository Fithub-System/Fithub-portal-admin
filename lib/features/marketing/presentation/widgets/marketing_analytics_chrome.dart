import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/kinetic_tokens.dart';
import '../fixtures/marketing_stitch_fixtures.dart';

/// Conversion Flow + Asset Library + footer metric tiles (AC-D1/D2 fixtures).
class ConversionFlowCard extends StatelessWidget {
  const ConversionFlowCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: KineticTokens.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsetsDirectional.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'marketing.conversion.title'.tr(),
            style: const TextStyle(
              color: KineticTokens.secondaryContainer,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'marketing.conversion.subtitle'.tr(),
            style: const TextStyle(
              color: Color(0xFFC4C9AC),
              fontSize: 11,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                MarketingStitchFixtures.conversionRate,
                style: const TextStyle(
                  color: KineticTokens.pureWhite,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsetsDirectional.only(bottom: 8),
                child: Icon(
                  Icons.trending_up,
                  color: KineticTokens.electricLime,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            width: double.infinity,
            child: CustomPaint(
              painter: _ConversionChartPainter(
                series: MarketingStitchFixtures.conversionSeries,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: MarketingStitchFixtures.conversionAxis
                .map(
                  (label) => Text(
                    label,
                    style: const TextStyle(
                      color: KineticTokens.zincGray,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          Text(
            'marketing.fixture'.tr(),
            style: const TextStyle(color: KineticTokens.zincGray, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class AssetLibraryCard extends StatelessWidget {
  const AssetLibraryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF21323E), Color(0xFF0E0E0E), Color(0xFF283500)],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.65),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'marketing.asset.title'.tr(),
                  style: const TextStyle(
                    color: KineticTokens.electricLime,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Text(
                  'marketing.asset.ready'.tr(),
                  style: const TextStyle(
                    color: KineticTokens.pureWhite,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'marketing.fixture'.tr(),
                  style: const TextStyle(
                    color: KineticTokens.zincGray,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const PositionedDirectional(
            end: 14,
            bottom: 14,
            child: Icon(Icons.arrow_outward, color: KineticTokens.electricLime),
          ),
        ],
      ),
    );
  }
}

class MarketingMetricTiles extends StatelessWidget {
  const MarketingMetricTiles({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 720;
        final tiles = [
          _MetricTile(
            icon: Icons.rocket_launch_outlined,
            iconColor: KineticTokens.electricLime,
            label: 'marketing.metrics.reach'.tr(),
            value: MarketingStitchFixtures.totalReach,
          ),
          _MetricTile(
            icon: Icons.ads_click,
            iconColor: KineticTokens.secondaryContainer,
            label: 'marketing.metrics.ctr'.tr(),
            value: MarketingStitchFixtures.avgClickThrough,
          ),
          _MetricTile(
            icon: Icons.savings_outlined,
            iconColor: KineticTokens.pureWhite,
            label: 'marketing.metrics.revenue'.tr(),
            value: MarketingStitchFixtures.revenueAttributed,
          ),
        ];
        if (wide) {
          return Row(
            children: [
              for (var i = 0; i < tiles.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
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

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.all(18),
      decoration: BoxDecoration(
        color: KineticTokens.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: KineticTokens.zincGray.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: KineticTokens.zincGray,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: KineticTokens.pureWhite,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversionChartPainter extends CustomPainter {
  _ConversionChartPainter({required this.series});
  final List<double> series;

  @override
  void paint(Canvas canvas, Size size) {
    if (series.isEmpty) return;
    final path = Path();
    final fill = Path();
    final dx = size.width / (series.length - 1);
    for (var i = 0; i < series.length; i++) {
      final x = dx * i;
      final y = size.height * (1 - series[i].clamp(0.0, 1.0));
      if (i == 0) {
        path.moveTo(x, y);
        fill.moveTo(x, size.height);
        fill.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fill.lineTo(x, y);
      }
    }
    fill.lineTo(size.width, size.height);
    fill.close();

    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            KineticTokens.secondaryContainer.withValues(alpha: 0.35),
            KineticTokens.secondaryContainer.withValues(alpha: 0.0),
          ],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = KineticTokens.secondaryContainer
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    final last = series.last.clamp(0.0, 1.0);
    canvas.drawCircle(
      Offset(size.width, size.height * (1 - last)),
      5,
      Paint()..color = KineticTokens.pureWhite,
    );
  }

  @override
  bool shouldRepaint(covariant _ConversionChartPainter oldDelegate) =>
      oldDelegate.series != series;
}
