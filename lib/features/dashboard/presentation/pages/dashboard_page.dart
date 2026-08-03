import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/kinetic_tokens.dart';
import '../../../connectivity/presentation/cubit/connectivity_cubit.dart';
import '../../../connectivity/presentation/widgets/safe_mode_banner.dart';
import '../cubit/dashboard_cubit.dart';
import '../widgets/admin_overview_dashboard.dart';

/// Standalone dashboard page (also embedded via [PortalHomeShell]).
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, connectivity) {
        return BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, dashboard) {
            final approved =
                dashboard.lastScanMessageKey == 'dashboard.scan.approved';
            final rejected =
                dashboard.lastScanMessageKey == 'dashboard.scan.rejected';

            return Scaffold(
              backgroundColor: KineticTokens.stitchBackground,
              body: Column(
                children: [
                  SafeModeBanner(visible: connectivity.isOffline),
                  Expanded(
                    child: AdminOverviewDashboard(
                      currentOccupancy: dashboard.currentOccupancy,
                      capacityLimit: dashboard.capacityLimit,
                      onOpenScanner: () {},
                      statusMessageKey: dashboard.statusMessageKey,
                      lastScanApproved: approved,
                      lastScanMemberName: dashboard.lastScanMemberName,
                      lastScanRejectReason:
                          rejected ? dashboard.lastScanRejectReason : null,
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
}
