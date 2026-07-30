import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/kinetic_tokens.dart';
import '../../../memberships/presentation/widgets/memberships_plans_panel.dart';
import '../cubit/member_roster_cubit.dart';
import '../widgets/member_roster_table.dart';

/// Member Management hub — roster + embedded plans (FEAT-07-R).
/// Stitch screen `9b35dd57f15443e99f7e798f6867acb6` (Member Management).
class MemberManagementScreen extends StatelessWidget {
  const MemberManagementScreen({super.key, required this.canWrite});

  /// Stitch Member Management (Stitch MCP unavailable — id from FSD).
  static const String stitchScreenId = '9b35dd57f15443e99f7e798f6867acb6';
  static const String stitchScreenTitle = 'Member Management';

  final bool canWrite;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'members.title'.tr(),
                  textAlign: TextAlign.start,
                  style: textTheme.headlineMedium?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'members.subtitle'.tr(),
                  textAlign: TextAlign.start,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                TabBar(
                  indicatorColor: KineticTokens.electricLime,
                  labelColor: KineticTokens.electricLime,
                  unselectedLabelColor: KineticTokens.zincGray,
                  tabs: [
                    Tab(text: 'members.tab.roster'.tr()),
                    Tab(text: 'members.tab.plans'.tr()),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: KineticTokens.zincGray),
          Expanded(
            child: TabBarView(
              children: [
                _RosterTab(canWrite: canWrite),
                MembershipsPlansPanel(canWrite: canWrite),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RosterTab extends StatelessWidget {
  const _RosterTab({required this.canWrite});

  final bool canWrite;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemberRosterCubit, MemberRosterState>(
      builder: (context, state) {
        if (state.status == MemberRosterStatus.loading ||
            state.status == MemberRosterStatus.initial) {
          return const Center(
            child: CircularProgressIndicator(
              color: KineticTokens.electricLime,
            ),
          );
        }

        if (state.status == MemberRosterStatus.failure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'members.error.roster'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: KineticTokens.zincGray,
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.read<MemberRosterCubit>().load(),
                  child: Text('memberships.retry'.tr()),
                ),
              ],
            ),
          );
        }

        return MemberRosterTable(
          members: state.members,
          canWrite: canWrite,
        );
      },
    );
  }
}
