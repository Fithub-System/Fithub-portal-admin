import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/kinetic_tokens.dart';

/// Circular Live Occupancy ring — Kinetic Monolith / FEAT-01 Admin blueprint.
///
/// Ring ~220px, stroke ~12px, card `#1A1A1A` / 16px radius, ~20px lime glow.
class LiveOccupancyRing extends StatelessWidget {
  const LiveOccupancyRing({
    super.key,
    required this.current,
    required this.capacity,
    this.size = KineticTokens.occupancyRingSize,
    this.activeColor,
    this.trackColor,
  });

  final int current;
  final int capacity;
  final double size;

  /// Active arc — defaults to Electric Lime `#CCFF00`; callers may pass
  /// `Theme.of(context).colorScheme.primaryContainer`.
  final Color? activeColor;
  final Color? trackColor;

  @override
  Widget build(BuildContext context) {
    final progress = capacity == 0 ? 0.0 : (current / capacity).clamp(0.0, 1.0);
    // FEAT-01 `#CCFF00`; optional override (e.g. primaryContainer).
    final arcColor = activeColor ?? KineticTokens.electricLime;
    final track = trackColor ?? KineticTokens.zincGray;

    return Container(
      width: size + 32,
      height: size + 32,
      decoration: BoxDecoration(
        color: KineticTokens.gunmetalCard,
        borderRadius: BorderRadius.circular(KineticTokens.dashboardCardRadius),
        boxShadow: [
          BoxShadow(
            color: KineticTokens.electricLime.withValues(alpha: 0.35),
            blurRadius: KineticTokens.occupancyGlowBlur,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: KineticTokens.electricLime.withValues(alpha: 0.15),
            blurRadius: KineticTokens.occupancyGlowBlur * 1.5,
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: OccupancyRingPainter(
              progress: progress,
              activeColor: arcColor,
              trackColor: track,
              strokeWidth: KineticTokens.occupancyRingStroke,
              glowBlur: KineticTokens.occupancyGlowBlur,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$current',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: arcColor,
                    ),
                  ),
                  Text(
                    '/ $capacity',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: KineticTokens.zincGray,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'dashboard.occupancy.live_label'.tr(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: KineticTokens.pureWhite,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Public painter so unit tests can assert Kinetic stroke / glow tokens.
class OccupancyRingPainter extends CustomPainter {
  const OccupancyRingPainter({
    required this.progress,
    required this.activeColor,
    required this.trackColor,
    this.strokeWidth = KineticTokens.occupancyRingStroke,
    this.glowBlur = KineticTokens.occupancyGlowBlur,
  });

  final double progress;
  final Color activeColor;
  final Color trackColor;
  final double strokeWidth;
  final double glowBlur;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const start = -math.pi / 2;
    final sweep = math.pi * 2 * progress.clamp(0.0, 1.0);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, start, math.pi * 2, false, trackPaint);

    if (sweep <= 0) return;

    // Premium lime glow (drop-shadow under the active arc).
    final glowPaint = Paint()
      ..color = activeColor.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 2
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowBlur);

    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawArc(rect, start, sweep, false, glowPaint);
    canvas.restore();

    // Soft outer halo
    final haloPaint = Paint()
      ..color = activeColor.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowBlur * 0.6);
    canvas.drawArc(rect, start, sweep, false, haloPaint);

    // Crisp active arc on top
    final activePaint = Paint()
      ..shader = ui.Gradient.sweep(
        center,
        [
          activeColor.withValues(alpha: 0.85),
          activeColor,
          activeColor.withValues(alpha: 0.95),
        ],
        const [0.0, 0.5, 1.0],
        TileMode.clamp,
        start,
        start + math.pi * 2,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, start, sweep, false, activePaint);
  }

  @override
  bool shouldRepaint(covariant OccupancyRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.glowBlur != glowBlur;
  }
}
