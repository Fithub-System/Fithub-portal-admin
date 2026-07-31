import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/kinetic_tokens.dart';
import '../../../access_scanner/presentation/screens/access_scanner_screen.dart';
import '../../../dashboard/presentation/cubit/dashboard_cubit.dart';

/// Fullscreen / focus Check-in Gate under Home (FEAT-12 Install I2).
///
/// Stitch G1 EN `3629845f7f1e402697f46cf5575e86da` ·
/// AR `bec9356e2cb941798e66fa804ac78854`.
/// Shell SafeMode zinc banner remains above this host (parent column).
class AccessScannerFocusHost extends StatelessWidget {
  const AccessScannerFocusHost({
    super.key,
    required this.onClose,
    this.scanner = const AccessScannerScreen(),
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
    final hasOverride =
        occupancyCurrent != null && occupancyCapacity != null;

    return ColoredBox(
      color: KineticTokens.deepCharcoal,
      child: Column(
        children: [
          Material(
            color: KineticTokens.gunmetalCard,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
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
                      child: Text(
                        'home.coming_soon.stitch_ref'.tr(
                          namedArgs: {'id': stitchId},
                        ),
                        textAlign: TextAlign.start,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          color: KineticTokens.zincGray.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    if (hasOverride)
                      _OccupancyChip(
                        current: occupancyCurrent!,
                        capacity: occupancyCapacity!,
                      )
                    else
                      BlocBuilder<DashboardCubit, DashboardState>(
                        builder: (context, dashboard) {
                          return _OccupancyChip(
                            current: dashboard.currentOccupancy,
                            capacity: dashboard.capacityLimit,
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(child: scanner),
        ],
      ),
    );
  }
}

class _OccupancyChip extends StatelessWidget {
  const _OccupancyChip({required this.current, required this.capacity});

  final int current;
  final int capacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('access-scanner-occupancy-chip'),
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: KineticTokens.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: KineticTokens.secondaryContainer.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        'home.scanner.occupancy_chip'.tr(
          namedArgs: {
            'current': '$current',
            'capacity': '$capacity',
          },
        ),
        style: const TextStyle(
          color: KineticTokens.secondaryContainer,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
