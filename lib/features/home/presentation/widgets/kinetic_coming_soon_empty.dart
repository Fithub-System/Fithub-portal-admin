import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/kinetic_tokens.dart';

/// Kinetic Coming soon empty — FEAT-11 Classes / Reports placeholders.
///
/// Pixel intent: Kinetic dark `#121212` / lime `#CCFF00` (no purple).
class KineticComingSoonEmpty extends StatelessWidget {
  const KineticComingSoonEmpty({
    super.key,
    required this.titleKey,
    required this.bodyKey,
    required this.stitchScreenIdEn,
    required this.stitchScreenIdAr,
    this.hintKey,
    this.icon = Icons.hourglass_empty_outlined,
  });

  final String titleKey;
  final String bodyKey;
  final String? hintKey;
  final String stitchScreenIdEn;
  final String stitchScreenIdAr;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isAr = context.locale.languageCode == 'ar';
    final stitchId = isAr ? stitchScreenIdAr : stitchScreenIdEn;

    return ColoredBox(
      color: KineticTokens.deepCharcoal,
      child: Center(
        child: Padding(
          padding: const EdgeInsetsDirectional.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 56, color: KineticTokens.electricLime),
                const SizedBox(height: 24),
                Text(
                  titleKey.tr(),
                  textAlign: TextAlign.center,
                  style: textTheme.titleLarge?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: KineticTokens.pureWhite,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  bodyKey.tr(),
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    height: 1.4,
                    color: KineticTokens.zincGray,
                  ),
                ),
                if (hintKey != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    hintKey!.tr(),
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 13,
                      color: KineticTokens.electricLime,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  'home.coming_soon.stitch_ref'.tr(
                    namedArgs: {'id': stitchId},
                  ),
                  textAlign: TextAlign.center,
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    color: KineticTokens.zincGray.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// FEAT-11 Classes Coming soon (Stitch G6).
///
/// EN `c3b2a1416ebb4f46a71aa108f418e51c` · AR `747d13fbf3b741d09c3a29e18d7b0bd4`.
/// No schedule CRUD / Backend calls (AC-B2).
class ClassesComingSoonPage extends StatelessWidget {
  const ClassesComingSoonPage({super.key});

  static const String stitchScreenIdEn = 'c3b2a1416ebb4f46a71aa108f418e51c';
  static const String stitchScreenIdAr = '747d13fbf3b741d09c3a29e18d7b0bd4';

  @override
  Widget build(BuildContext context) {
    return const KineticComingSoonEmpty(
      titleKey: 'classes.coming_soon.title',
      bodyKey: 'classes.coming_soon.body',
      stitchScreenIdEn: stitchScreenIdEn,
      stitchScreenIdAr: stitchScreenIdAr,
      icon: Icons.fitness_center_outlined,
    );
  }
}

/// FEAT-11 Reports Coming soon (Stitch G6) + FEAT-10 Gym Settings nest (G2).
///
/// EN `ace7bf6e830b4e9f8963cfa5dd07909b` · AR `82188fd0c27a4baa923ead6221e04d7b`.
/// No analytics Backend (AC-C2). Gym Settings entry is nested — not a rail tab.
class ReportsComingSoonPage extends StatelessWidget {
  const ReportsComingSoonPage({super.key});

  static const String stitchScreenIdEn = 'ace7bf6e830b4e9f8963cfa5dd07909b';
  static const String stitchScreenIdAr = '82188fd0c27a4baa923ead6221e04d7b';

  @override
  Widget build(BuildContext context) {
    return const KineticComingSoonEmpty(
      titleKey: 'reports.coming_soon.title',
      bodyKey: 'reports.coming_soon.body',
      hintKey: 'reports.coming_soon.hint',
      stitchScreenIdEn: stitchScreenIdEn,
      stitchScreenIdAr: stitchScreenIdAr,
      icon: Icons.insights_outlined,
    );
  }
}

/// Reports destination — Coming soon + Gym Settings nest (FEAT-10 Install I3).
///
/// Stitch G2 entry: Reports → Gym Settings (also via avatar menu).
class ReportsShellPage extends StatelessWidget {
  const ReportsShellPage({super.key, required this.onOpenGymSettings});

  final VoidCallback onOpenGymSettings;

  static const String stitchScreenIdEn = ReportsComingSoonPage.stitchScreenIdEn;
  static const String stitchScreenIdAr = ReportsComingSoonPage.stitchScreenIdAr;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isAr = context.locale.languageCode == 'ar';
    final settingsStitchId = isAr
        ? KineticTokens.stitchGymSettingsScreenIdAr
        : KineticTokens.stitchGymSettingsScreenId;

    return ColoredBox(
      color: KineticTokens.deepCharcoal,
      child: ListView(
        padding: const EdgeInsetsDirectional.all(24),
        children: [
          Icon(
            Icons.insights_outlined,
            size: 48,
            color: KineticTokens.electricLime,
          ),
          const SizedBox(height: 16),
          Text(
            'reports.coming_soon.title'.tr(),
            textAlign: TextAlign.start,
            style: textTheme.titleLarge?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: KineticTokens.pureWhite,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'reports.coming_soon.body'.tr(),
            textAlign: TextAlign.start,
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              color: KineticTokens.zincGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'reports.coming_soon.hint'.tr(),
            textAlign: TextAlign.start,
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              color: KineticTokens.electricLime,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'home.coming_soon.stitch_ref'.tr(
              namedArgs: {
                'id': isAr ? stitchScreenIdAr : stitchScreenIdEn,
              },
            ),
            style: textTheme.labelSmall?.copyWith(
              fontSize: 10,
              color: KineticTokens.zincGray.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'reports.settings_nest.heading'.tr(),
            style: textTheme.labelLarge?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: KineticTokens.zincGray,
            ),
          ),
          const SizedBox(height: 12),
          Material(
            color: KineticTokens.surfaceContainerLow,
            borderRadius: BorderRadius.circular(
              KineticTokens.dashboardCardRadius,
            ),
            child: InkWell(
              onTap: onOpenGymSettings,
              borderRadius: BorderRadius.circular(
                KineticTokens.dashboardCardRadius,
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.all(16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.settings_outlined,
                      color: KineticTokens.electricLime,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'reports.settings_nest.gym_settings'.tr(),
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: KineticTokens.pureWhite,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'reports.settings_nest.gym_settings_body'.tr(),
                            style: textTheme.bodySmall?.copyWith(
                              color: KineticTokens.zincGray,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'home.coming_soon.stitch_ref'.tr(
                              namedArgs: {'id': settingsStitchId},
                            ),
                            style: textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              color: KineticTokens.zincGray.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: KineticTokens.zincGray,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
