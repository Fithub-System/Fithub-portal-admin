import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/kinetic_tokens.dart';

/// Stitch Access Gate 1 + optional Access Granted stack (Overview col-span-4).
///
/// Tap / CTA opens FEAT-12 Check-in Gate focus (not a rail tab).
class AccessGatePanel extends StatelessWidget {
  const AccessGatePanel({
    super.key,
    required this.onOpenScanner,
    this.lastScanApproved = false,
    this.lastScanMemberName,
    this.lastScanRejectReason,
  });

  final VoidCallback onOpenScanner;
  final bool lastScanApproved;
  final String? lastScanMemberName;
  final String? lastScanRejectReason;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: KineticTokens.surfaceContainerLow,
          borderRadius: BorderRadius.circular(KineticTokens.dashboardCardRadius),
          child: InkWell(
            onTap: onOpenScanner,
            borderRadius: BorderRadius.circular(
              KineticTokens.dashboardCardRadius,
            ),
            child: Container(
              padding: const EdgeInsetsDirectional.all(32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  KineticTokens.dashboardCardRadius,
                ),
                border: Border.all(color: const Color(0xFF262626)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'dashboard.access_gate.title'.tr(),
                          textAlign: TextAlign.start,
                          style: textTheme.titleMedium?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: KineticTokens.onSurface,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          _StatusDot(color: KineticTokens.primaryContainer),
                          const SizedBox(width: 4),
                          const _StatusDot(color: Color(0xFF404040)),
                          const SizedBox(width: 4),
                          const _StatusDot(color: Color(0xFF404040)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF171717),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF262626),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code_2,
                            size: 48,
                            color: KineticTokens.zincGray.withValues(
                              alpha: 0.85,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'dashboard.access_gate.waiting'.tr(),
                            textAlign: TextAlign.center,
                            style: textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.6,
                              color: KineticTokens.zincGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'dashboard.access_gate.status_label'.tr(),
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: KineticTokens.zincGray,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: KineticTokens.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'dashboard.access_gate.ready'.tr(),
                            style: textTheme.labelSmall?.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.6,
                              color: KineticTokens.primaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
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
                      child: Text(
                        'home.scanner.open_cta'.tr(),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (lastScanApproved &&
            (lastScanMemberName?.isNotEmpty ?? false)) ...[
          const SizedBox(height: 32),
          _AccessGrantedCard(memberName: lastScanMemberName!),
        ] else if (lastScanRejectReason != null &&
            lastScanRejectReason!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'dashboard.scan.rejected'.tr(
              namedArgs: {'reason': lastScanRejectReason!},
            ),
            textAlign: TextAlign.start,
            style: textTheme.bodySmall?.copyWith(
              fontSize: 12,
              color: KineticTokens.stitchError,
            ),
          ),
        ],
      ],
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _AccessGrantedCard extends StatelessWidget {
  const _AccessGrantedCard({required this.memberName});

  final String memberName;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsetsDirectional.all(24),
      decoration: BoxDecoration(
        color: KineticTokens.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(KineticTokens.dashboardCardRadius),
        border: Border.all(
          color: KineticTokens.primaryContainer,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: KineticTokens.primaryContainer.withValues(alpha: 0.1),
            blurRadius: 50,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: KineticTokens.railSurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: KineticTokens.primaryContainer,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  color: KineticTokens.onSurface,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      memberName,
                      textAlign: TextAlign.start,
                      style: textTheme.titleLarge?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        color: KineticTokens.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: KineticTokens.primaryContainer.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: KineticTokens.primaryContainer.withValues(
                            alpha: 0.2,
                          ),
                        ),
                      ),
                      child: Text(
                        'dashboard.access_gate.active_member'.tr(),
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                          color: KineticTokens.primaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: KineticTokens.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              'dashboard.access_gate.granted'.tr(),
              style: textTheme.labelLarge?.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.6,
                color: KineticTokens.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
