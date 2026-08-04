import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/kinetic_tokens.dart';
import '../../../access_scanner/presentation/screens/access_scanner_screen.dart';
import '../../../access_scanner/presentation/widgets/check_in_gate_layout.dart';

/// Fullscreen / focus Check-in Gate under Home (FEAT-12 + FEAT-16 VF4).
///
/// Stitch G1 EN `3629845f7f1e402697f46cf5575e86da` ·
/// AR `bec9356e2cb941798e66fa804ac78854`.
/// Shell SafeMode zinc banner + 6-rail remain outside this host.
class AccessScannerFocusHost extends StatelessWidget {
  const AccessScannerFocusHost({
    super.key,
    required this.onClose,
    this.scanner = const AccessScannerScreen(embedded: true),
    this.occupancyCurrent,
    this.occupancyCapacity,
  });

  final VoidCallback onClose;

  /// Override in widget tests to avoid `mobile_scanner` platform channels.
  final Widget scanner;

  /// Optional occupancy override for widget tests (skips [DashboardCubit]).
  final int? occupancyCurrent;
  final int? occupancyCapacity;

  static const String stitchScreenIdEn =
      KineticTokens.stitchAccessScannerScreenId;
  static const String stitchScreenIdAr =
      KineticTokens.stitchAccessScannerScreenIdAr;

  @override
  Widget build(BuildContext context) {
    final isAr = context.locale.languageCode == 'ar';
    final stitchId = isAr ? stitchScreenIdAr : stitchScreenIdEn;

    return ColoredBox(
      color: KineticTokens.stitchBackground,
      child: Column(
        children: [
          Material(
            color: KineticTokens.stitchBackground,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 24, 8),
                child: Row(
                  children: [
                    IconButton(
                      key: const Key('access-scanner-focus-close'),
                      tooltip: 'home.scanner.close'.tr(),
                      onPressed: onClose,
                      icon: const Icon(
                        Icons.close,
                        color: KineticTokens.pureWhite,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'access_scanner.gate.brand'.tr(),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.8,
                              color: KineticTokens.pureWhite,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'access_scanner.gate.eyebrow'.tr(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: KineticTokens.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'home.coming_soon.stitch_ref'.tr(
                              namedArgs: {'id': stitchId},
                            ),
                            style: TextStyle(
                              fontSize: 10,
                              color: KineticTokens.zincGray.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: CheckInGateLayout(
              scannerViewport: scanner,
              occupancyCurrent: occupancyCurrent,
              occupancyCapacity: occupancyCapacity,
            ),
          ),
        ],
      ),
    );
  }
}
