import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/kinetic_tokens.dart';

/// Home → Open scanner CTA / panel (FEAT-12 Install I2).
///
/// Stitch G1 Check-in Gate — entry under Home, not a rail destination.
/// EN `3629845f7f1e402697f46cf5575e86da` · AR `bec9356e2cb941798e66fa804ac78854`.
class HomeAccessScannerCta extends StatelessWidget {
  const HomeAccessScannerCta({super.key, required this.onOpenScanner});

  final VoidCallback onOpenScanner;

  static const String stitchScreenIdEn =
      KineticTokens.stitchAccessScannerScreenId;
  static const String stitchScreenIdAr =
      KineticTokens.stitchAccessScannerScreenIdAr;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isAr = context.locale.languageCode == 'ar';
    final stitchId = isAr ? stitchScreenIdAr : stitchScreenIdEn;

    return Material(
      color: KineticTokens.surfaceContainerLow,
      borderRadius: BorderRadius.circular(KineticTokens.dashboardCardRadius),
      child: InkWell(
        onTap: onOpenScanner,
        borderRadius: BorderRadius.circular(KineticTokens.dashboardCardRadius),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsetsDirectional.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              KineticTokens.dashboardCardRadius,
            ),
            border: Border.all(
              color: KineticTokens.electricLime.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: KineticTokens.electricLime.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner,
                      color: KineticTokens.electricLime,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'home.scanner.panel_title'.tr(),
                          textAlign: TextAlign.start,
                          style: textTheme.titleMedium?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: KineticTokens.pureWhite,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'home.scanner.panel_subtitle'.tr(),
                          textAlign: TextAlign.start,
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: KineticTokens.zincGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('home-open-scanner-cta'),
                  onPressed: onOpenScanner,
                  style: FilledButton.styleFrom(
                    backgroundColor: KineticTokens.electricLime,
                    foregroundColor: KineticTokens.deepCharcoal,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.fullscreen),
                  label: Text(
                    'home.scanner.open_cta'.tr(),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'home.coming_soon.stitch_ref'.tr(namedArgs: {'id': stitchId}),
                textAlign: TextAlign.start,
                style: textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  color: KineticTokens.zincGray.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
