import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/kinetic_tokens.dart';

/// Stitch Expiring Memberships table chrome (Overview mid col-span-8).
///
/// Rows stay empty until a memberships expiry query is contracted; headers /
/// RENEW ALL chrome match Spec Card.
class ExpiringMembershipsCard extends StatelessWidget {
  const ExpiringMembershipsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: KineticTokens.surfaceContainerLow,
        borderRadius: BorderRadius.circular(KineticTokens.dashboardCardRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.all(32),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'dashboard.expiring.title'.tr(),
                        textAlign: TextAlign.start,
                        style: textTheme.titleLarge?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: KineticTokens.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'dashboard.expiring.subtitle'.tr(),
                        textAlign: TextAlign.start,
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 12,
                          color: KineticTokens.zincGray,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: KineticTokens.primaryContainer,
                    disabledForegroundColor: KineticTokens.primaryContainer
                        .withValues(alpha: 0.7),
                    side: BorderSide(
                      color: KineticTokens.primaryContainer.withValues(
                        alpha: 0.2,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                  child: Text('dashboard.expiring.renew_all'.tr()),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: KineticTokens.pureWhite.withValues(alpha: 0.05),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        'dashboard.expiring.col_member'.tr(),
                        style: _headerStyle(textTheme),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'dashboard.expiring.col_plan'.tr(),
                        textAlign: TextAlign.center,
                        style: _headerStyle(textTheme),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'dashboard.expiring.col_expiration'.tr(),
                        textAlign: TextAlign.end,
                        style: _headerStyle(textTheme),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'dashboard.expiring.empty'.tr(),
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: KineticTokens.zincGray,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextStyle? _headerStyle(TextTheme textTheme) {
    return textTheme.labelSmall?.copyWith(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.6,
      color: KineticTokens.zincGray,
    );
  }
}
