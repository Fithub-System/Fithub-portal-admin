import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/kinetic_tokens.dart';
import '../../../connectivity/presentation/cubit/connectivity_cubit.dart';
import '../../../connectivity/presentation/widgets/safe_mode_banner.dart';
import '../cubit/dashboard_cubit.dart';
import '../widgets/live_occupancy_ring.dart';

/// Standalone dashboard page (also embedded via [PortalHomeShell]).
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, connectivity) {
        return BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, dashboard) {
            final gymTitle = dashboard.gymName.isEmpty
                ? 'dashboard.gym_fallback'.tr()
                : dashboard.gymName;

            return Scaffold(
              backgroundColor: KineticTokens.deepCharcoal,
              body: Column(
                children: [
                  SafeModeBanner(visible: connectivity.isOffline),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            gymTitle,
                            textAlign: TextAlign.start,
                            style: textTheme.titleLarge?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: KineticTokens.pureWhite,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            connectivity.isOnline
                                ? 'dashboard.status.online'.tr()
                                : 'dashboard.status.offline'.tr(),
                            textAlign: TextAlign.start,
                            style: textTheme.bodyMedium?.copyWith(
                              fontSize: 13,
                              color: KineticTokens.zincGray,
                            ),
                          ),
                          const Spacer(),
                          Center(
                            child: LiveOccupancyRing(
                              current: dashboard.currentOccupancy,
                              capacity: dashboard.capacityLimit,
                            ),
                          ),
                          const Spacer(),
                          if (dashboard.lastScanMessageKey != null)
                            Text(
                              _scanMessage(dashboard),
                              textAlign: TextAlign.start,
                              style: textTheme.bodyMedium?.copyWith(
                                fontSize: 13,
                                color: KineticTokens.electricLime,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _scanMessage(DashboardState dashboard) {
    if (dashboard.lastScanMessageKey == 'dashboard.scan.approved') {
      return 'dashboard.scan.approved'.tr(
        namedArgs: {'name': dashboard.lastScanMemberName ?? ''},
      );
    }
    if (dashboard.lastScanMessageKey == 'dashboard.scan.rejected') {
      return 'dashboard.scan.rejected'.tr(
        namedArgs: {'reason': dashboard.lastScanRejectReason ?? ''},
      );
    }
    return dashboard.lastScanMessageKey?.tr() ?? '';
  }
}
