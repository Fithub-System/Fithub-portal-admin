import 'package:flutter/material.dart';

import '../../../../config/theme/kinetic_tokens.dart';

/// Neon target grid overlay for the Access Scanner camera (FEAT-01 §3).
class ScannerTargetOverlay extends StatelessWidget {
  const ScannerTargetOverlay({super.key});

  static const double frameSize = 260;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: SizedBox(
          width: frameSize,
          height: frameSize,
          child: CustomPaint(
            painter: _TargetGridPainter(),
          ),
        ),
      ),
    );
  }
}

class _TargetGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final glow = Paint()
      ..color = KineticTokens.electricLime.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final line = Paint()
      ..color = KineticTokens.electricLime
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(16));

    canvas.drawRRect(rrect, glow);
    canvas.drawRRect(rrect, line);

    const corner = 28.0;
    _drawCorner(canvas, line, Offset(0, 0), corner, true, true);
    _drawCorner(canvas, line, Offset(size.width, 0), corner, false, true);
    _drawCorner(canvas, line, Offset(0, size.height), corner, true, false);
    _drawCorner(
      canvas,
      line,
      Offset(size.width, size.height),
      corner,
      false,
      false,
    );

    final thirdW = size.width / 3;
    final thirdH = size.height / 3;
    final grid = Paint()
      ..color = KineticTokens.electricLime.withValues(alpha: 0.25)
      ..strokeWidth = 1;

    for (var i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(thirdW * i, 0),
        Offset(thirdW * i, size.height),
        grid,
      );
      canvas.drawLine(
        Offset(0, thirdH * i),
        Offset(size.width, thirdH * i),
        grid,
      );
    }
  }

  void _drawCorner(
    Canvas canvas,
    Paint paint,
    Offset origin,
    double length,
    bool left,
    bool top,
  ) {
    final dx = left ? 1.0 : -1.0;
    final dy = top ? 1.0 : -1.0;
    canvas.drawLine(origin, origin + Offset(length * dx, 0), paint);
    canvas.drawLine(origin, origin + Offset(0, length * dy), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
