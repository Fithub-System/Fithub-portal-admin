import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/kinetic_tokens.dart';

/// SafeMode banner shown only during offline transitions (FEAT-01 AC1).
class SafeModeBanner extends StatelessWidget {
  const SafeModeBanner({super.key, required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: visible
          ? Container(
              key: const ValueKey('safe-mode-on'),
              height: KineticTokens.safeModeBannerHeight,
              width: double.infinity,
              color: KineticTokens.zincGray,
              alignment: AlignmentDirectional.center,
              child: Text(
                KineticTokens.safeModeMessageKey.tr(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: KineticTokens.pureWhite,
                    ),
              ),
            )
          : const SizedBox.shrink(key: ValueKey('safe-mode-off')),
    );
  }
}
