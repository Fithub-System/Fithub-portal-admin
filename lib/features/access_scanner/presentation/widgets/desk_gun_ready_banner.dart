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
                  style: const TextStyle(
                    color: KineticTokens.electricLime,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
                const Spacer(),
                Text(
                  'access_scanner.gun.hid'.tr().toUpperCase(),
                  style: const TextStyle(
                    color: KineticTokens.zincGray,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Icon(
              Icons.qr_code_2,
              color: KineticTokens.electricLime,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'access_scanner.gun.headline'.tr().toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
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
              style: const TextStyle(
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
                style: const TextStyle(
                  color: KineticTokens.zincGray,
                  fontSize: 12,
                ),
              ),
            ),
            if (errorVisible) ...[
              const SizedBox(height: 12),
              Container(
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
                        style: const TextStyle(
                          color: KineticTokens.peakCoral,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (onUseCamera != null) ...[
              const SizedBox(height: 16),
              Align(
                alignment: AlignmentDirectional.center,
                child: TextButton(
                  key: const Key('gun-use-camera'),
                  onPressed: onUseCamera,
                  child: Text(
                    'access_scanner.gun.use_camera'.tr(),
                    style: const TextStyle(
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
