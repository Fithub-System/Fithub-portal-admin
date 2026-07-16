import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../config/theme/kinetic_tokens.dart';
import '../../../connectivity/presentation/cubit/connectivity_cubit.dart';
import '../../../connectivity/presentation/widgets/safe_mode_banner.dart';
import '../cubit/dashboard_cubit.dart';
import '../widgets/live_occupancy_ring.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, connectivity) {
        return BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, dashboard) {
            return Scaffold(
              backgroundColor: KineticTokens.deepCharcoal,
              body: Column(
                children: [
                  SafeModeBanner(visible: connectivity.isOffline),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dashboard.gymName,
                            style: GoogleFonts.lexend(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: KineticTokens.pureWhite,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            connectivity.isOnline
                                ? 'Online — cloud sync active'
                                : 'Offline — local SafeMode active',
                            style: GoogleFonts.lexend(
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
                          if (dashboard.lastScanMessage != null)
                            Text(
                              dashboard.lastScanMessage!,
                              style: GoogleFonts.lexend(
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
}
