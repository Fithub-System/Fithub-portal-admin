import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/kinetic_tokens.dart';
import '../../../gym_onboarding/presentation/widgets/stitch_kinetic_chrome.dart';

/// FEAT-97 gun-active banner — Stitch `8b38c6168f824bebab709b919f2dc24f`.
class DeskGunReadyBanner extends StatelessWidget {
  const DeskGunReadyBanner({
    super.key,
    this.onUseCamera,
    this.errorVisible = false,
  });

  final VoidCallback? onUseCamera;
  final bool errorVisible;

  static const String stitchScreenIdEn = '8b38c6168f824bebab709b919f2dc24f';
  static const String stitchScreenIdAr = '210e882c2bb44d71bac5aa78a1e0a493';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: StitchKineticCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: KineticTokens.electricLime,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'access_scanner.gun.ready'.tr().toUpperCase(),
                  style: StitchKineticChrome.text(
                    context,
                    color: KineticTokens.electricLime,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
                const Spacer(),
                Text(
                  'access_scanner.gun.hid'.tr().toUpperCase(),
                  style: StitchKineticChrome.text(
                    context,
                    color: KineticTokens.zincGray,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const SizedBox(
              height: 88,
              child: CustomPaint(
                painter: _KineticReticlePainter(),
                child: SizedBox.expand(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'access_scanner.gun.headline'.tr().toUpperCase(),
              textAlign: TextAlign.center,
              style: StitchKineticChrome.text(
                context,
                color: KineticTokens.pureWhite,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'access_scanner.gun.body'.tr(),
              textAlign: TextAlign.center,
              style: StitchKineticChrome.text(
                context,
                color: KineticTokens.zincGray,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: KineticTokens.deepCharcoal,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'access_scanner.gun.last_empty'.tr(),
                style: StitchKineticChrome.text(
                  context,
                  color: KineticTokens.zincGray,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Opacity(
              opacity: errorVisible ? 1 : 0.55,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: KineticTokens.peakCoral.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.volume_up,
                      color: KineticTokens.peakCoral,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'access_scanner.gun.invalid'.tr().toUpperCase(),
                        style: StitchKineticChrome.text(
                          context,
                          color: KineticTokens.peakCoral,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (onUseCamera != null) ...[
              const SizedBox(height: 16),
              Align(
                alignment: AlignmentDirectional.center,
                child: TextButton(
                  key: const Key('gun-use-camera'),
                  onPressed: onUseCamera,
                  child: Text(
                    'access_scanner.gun.use_camera'.tr(),
                    style: StitchKineticChrome.text(
                      context,
                      color: KineticTokens.electricLime,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Brand Lock `lightning_qr_scanner` — lime bolt through a sharp QR frame.
class _KineticReticlePainter extends CustomPainter {
  const _KineticReticlePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final lime = Paint()
      ..color = KineticTokens.electricLime
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.square;
    final frame = Paint()
      ..color = KineticTokens.onSurface
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.square;

    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    const arm = 18.0;
    const gap = 28.0;

    void corner(double x, double y, double dx, double dy) {
      canvas.drawLine(Offset(x, y), Offset(x + dx * arm, y), frame);
      canvas.drawLine(Offset(x, y), Offset(x, y + dy * arm), frame);
    }

    corner(cx - gap, cy - gap, 1, 1);
    corner(cx + gap, cy - gap, -1, 1);
    corner(cx - gap, cy + gap, 1, -1);
    corner(cx + gap, cy + gap, -1, -1);

    final bolt = Path()
      ..moveTo(cx + 4, cy - 22)
      ..lineTo(cx - 8, cy + 2)
      ..lineTo(cx + 2, cy + 2)
      ..lineTo(cx - 4, cy + 22)
      ..lineTo(cx + 10, cy - 2)
      ..lineTo(cx, cy - 2)
      ..close();
    canvas.drawPath(
      bolt,
      Paint()
        ..color = KineticTokens.electricLime
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(bolt, lime);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
