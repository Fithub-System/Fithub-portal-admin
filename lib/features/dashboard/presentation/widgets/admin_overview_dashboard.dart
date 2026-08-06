import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/kinetic_tokens.dart';
import 'access_gate_panel.dart';
import 'daily_yield_card.dart';
import 'expiring_memberships_card.dart';
import 'live_occupancy_gauge.dart';
import 'overview_footer_stats.dart';

/// FEAT-16 VF1 / VF1-R — Stitch Admin Overview Dashboard composition.
///
/// Screen `216e0407184f4c39bd501ed436c1e88b`. Regions match Visual Spec Card
/// (+ VF1-R §4.1 fixtures). Live occupancy + Access Gate → scanner preserved
/// (FEAT-04 / FEAT-12). Yield / expirations / footer / Access Granted ship
/// Stitch sample fixtures when unbound.
class AdminOverviewDashboard extends StatelessWidget {
  const AdminOverviewDashboard({
    super.key,
    required this.currentOccupancy,
    required this.capacityLimit,
    required this.onOpenScanner,
    this.statusMessageKey,
    this.lastScanMemberName,
    this.lastScanApproved = false,
    this.lastScanRejectReason,
  });

  final int currentOccupancy;
  final int capacityLimit;
  final VoidCallback onOpenScanner;
  final String? statusMessageKey;
  final String? lastScanMemberName;
  final bool lastScanApproved;
  final String? lastScanRejectReason;

  static const String stitchScreenId =
      KineticTokens.stitchOccupancyScreenId;

  /// Breakpoint where hero becomes 7/5 and mid becomes 8/4 (≈ Tailwind lg).
  static const double wideBreakpoint = 1024;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= wideBreakpoint;
        return SingleChildScrollView(
          padding: const EdgeInsetsDirectional.all(40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (statusMessageKey != null) ...[
                Text(
                  statusMessageKey!.tr(),
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: KineticTokens.electricLime,
                      ),
                ),
                const SizedBox(height: 16),
              ],
              _HeroRow(
                wide: wide,
                currentOccupancy: currentOccupancy,
                capacityLimit: capacityLimit,
              ),
              const SizedBox(height: 40),
              _MidRow(
                wide: wide,
                onOpenScanner: onOpenScanner,
                lastScanApproved: lastScanApproved,
                lastScanMemberName: lastScanMemberName,
                lastScanRejectReason: lastScanRejectReason,
              ),
              const SizedBox(height: 40),
              const OverviewFooterStats(),
            ],
          ),
        );
      },
    );
  }
}

class _HeroRow extends StatelessWidget {
  const _HeroRow({
    required this.wide,
    required this.currentOccupancy,
    required this.capacityLimit,
  });

  final bool wide;
  final int currentOccupancy;
  final int capacityLimit;

  @override
  Widget build(BuildContext context) {
    final occupancy = LiveOccupancyGauge(
      current: currentOccupancy,
      capacity: capacityLimit,
    );
    const yield = DailyYieldCard();

    if (!wide) {
      return Column(
        children: [
          occupancy,
          const SizedBox(height: 32),
          yield,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 7, child: occupancy),
        const SizedBox(width: 32),
        const Expanded(flex: 5, child: yield),
      ],
    );
  }
}

class _MidRow extends StatelessWidget {
  const _MidRow({
    required this.wide,
    required this.onOpenScanner,
    required this.lastScanApproved,
    this.lastScanMemberName,
    this.lastScanRejectReason,
  });

  final bool wide;
  final VoidCallback onOpenScanner;
  final bool lastScanApproved;
  final String? lastScanMemberName;
  final String? lastScanRejectReason;

  @override
  Widget build(BuildContext context) {
    const memberships = ExpiringMembershipsCard();
    final gate = AccessGatePanel(
      onOpenScanner: onOpenScanner,
      lastScanApproved: lastScanApproved,
      lastScanMemberName: lastScanMemberName,
      lastScanRejectReason: lastScanRejectReason,
    );

    if (!wide) {
      return Column(
        children: [
          memberships,
          const SizedBox(height: 32),
          gate,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(flex: 8, child: memberships),
        const SizedBox(width: 32),
        Expanded(flex: 4, child: gate),
      ],
    );
  }
}
