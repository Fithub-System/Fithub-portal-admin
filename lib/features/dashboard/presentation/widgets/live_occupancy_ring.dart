import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../config/theme/kinetic_tokens.dart';

/// Circular Live Occupancy ring from FEAT-01 Admin Portal blueprint.
class LiveOccupancyRing extends StatelessWidget {
  const LiveOccupancyRing({
    super.key,
    required this.current,
    required this.capacity,
    this.size = KineticTokens.occupancyRingSize,
  });

  final int current;
  final int capacity;
  final double size;

  @override
  Widget build(BuildContext context) {
    final progress = capacity == 0 ? 0.0 : (current / capacity).clamp(0.0, 1.0);

    return Container(
      width: size + 32,
      height: size + 32,
      decoration: BoxDecoration(
        color: KineticTokens.gunmetalCard,
        borderRadius: BorderRadius.circular(
          KineticTokens.dashboardCardRadius,
        ),
        boxShadow: [
          BoxShadow(
            color: KineticTokens.electricLime.withValues(alpha: 0.25),
            blurRadius: KineticTokens.occupancyGlowBlur,
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _OccupancyRingPainter(progress: progress),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$current',
                    style: GoogleFonts.lexend(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: KineticTokens.electricLime,
                    ),
                  ),
                  Text(
                    '/ $capacity',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: KineticTokens.zincGray,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'LIVE OCCUPANCY',
                    style: GoogleFonts.lexend(
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

class _OccupancyRingPainter extends CustomPainter {
  const _OccupancyRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - KineticTokens.occupancyRingStroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = KineticTokens.zincGray
      ..style = PaintingStyle.stroke
      ..strokeWidth = KineticTokens.occupancyRingStroke
      ..strokeCap = StrokeCap.round;

    final activePaint = Paint()
      ..color = KineticTokens.electricLime
      ..style = PaintingStyle.stroke
      ..strokeWidth = KineticTokens.occupancyRingStroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2);

    canvas.drawArc(rect, -math.pi / 2, math.pi * 2, false, trackPaint);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _OccupancyRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
