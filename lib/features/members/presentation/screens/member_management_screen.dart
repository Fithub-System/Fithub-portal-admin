import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/kinetic_tokens.dart';
import '../../../../injection_container.dart';
import '../../../add_member/inject_add_member.dart' as add_member_di;
import '../../../add_member/presentation/screens/add_member_screen.dart';
import '../../../auth/presentation/widgets/stitch_auth_snackbar.dart';
import '../../../memberships/presentation/cubit/memberships_cubit.dart';
import '../../../memberships/presentation/widgets/memberships_plans_panel.dart';
import '../cubit/member_roster_cubit.dart';
import '../widgets/member_roster_table.dart';
import '../widgets/members_roster_chrome.dart';
import '../widgets/members_stats_bento.dart';

/// Member Management / Active Roster — Stitch `9b35dd57f15443e99f7e798f6867acb6`.
///
/// FEAT-59: opens with cloud refresh; empty live roster shows empty chrome
/// (fixtures only for widget tests / explicit demo). FEAT-07 assign + plans
/// (via Filter Type sheet), FEAT-13 Add Member, FEAT-61 renew/freeze preserved.
class MemberManagementScreen extends StatefulWidget {
  const MemberManagementScreen({
    super.key,
    required this.canWrite,
    this.canRenew = false,
    this.canFreeze = false,
    this.canEnroll = false,
  });

  /// Stitch Member Management (DESKTOP).
  static const String stitchScreenId = '9b35dd57f15443e99f7e798f6867acb6';
  static const String stitchScreenIdAr = '60b6a0e1f7fb4419b1b0e774ec8bdb32';
  static const String stitchScreenTitle = 'Member Management';

  /// FEAT-07 Admin-only assign / plan writes.
  final bool canWrite;

  /// FEAT-61 Admin-only renew.
  final bool canRenew;

  /// FEAT-61 Admin + Receptionist freeze/unfreeze.
  final bool canFreeze;

  /// FEAT-13 AC-B4 — Admin-only Add New Member navigation.
  final bool canEnroll;

  @override
  State<MemberManagementScreen> createState() => _MemberManagementScreenState();
}

class _MemberManagementScreenState extends State<MemberManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Freeze actions need policy rows (no policy ⇒ freeze disabled).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MembershipsCubit>().loadFreezePolicies();
    });
  }

  Future<void> _openAddMember(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => add_member_di.createAddMemberBloc(
            InjectionContainer.locator,
          ),
          child: AddMemberScreen(
            onEnrolled: (messageKey) {
              context.read<MemberRosterCubit>().refreshFromCloud();
              if (context.mounted) {
                StitchAuthSnackbar.show(context, messageKey.tr());
              }
            },
          ),
        ),
      ),
    );
  }

  Future<void> _openPlansSheet(BuildContext context) async {
    final membershipsCubit = context.read<MembershipsCubit>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: KineticTokens.surfaceContainerLow,
      builder: (sheetContext) {
        return BlocProvider<MembershipsCubit>.value(
          value: membershipsCubit,
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.85,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 8, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'memberships.plans_heading'.tr(),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: KineticTokens.pureWhite,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        icon: const Icon(
                          Icons.close,
                          color: KineticTokens.zincGray,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: KineticTokens.zincGray),
                Expanded(
                  child: MembershipsPlansPanel(canWrite: widget.canWrite),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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

        // FEAT-59 AC-A2: never mask empty live roster with Stitch sample rows.
        final rows = state.members;
        final showRetryBanner = state.status == MemberRosterStatus.failure;

        return ColoredBox(
          color: KineticTokens.stitchBackground,
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.showingCachedOffline) ...[
                  Text(
                    'members.status.offline_stale'.tr(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: KineticTokens.zincGray,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (showRetryBanner) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'members.error.roster'.tr(),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: KineticTokens.zincGray),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context
                            .read<MemberRosterCubit>()
                            .refreshFromCloud(),
                        child: Text('memberships.retry'.tr()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                _Header(
                  onAdd: widget.canEnroll
                      ? () => _openAddMember(context)
                      : null,
                  onFilter: () => _openPlansSheet(context),
                ),
                const SizedBox(height: 32),
                MembersStatsBento(
                  members: rows,
                  usingFixtures: false,
                ),
                const SizedBox(height: 32),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: KineticTokens.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF444933).withValues(alpha: 0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: rows.isEmpty
                        ? _EmptyRosterChrome(
                            onRetry: () => context
                                .read<MemberRosterCubit>()
                                .refreshFromCloud(),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              MemberRosterTable(
                                members: rows,
                                canAssign: widget.canWrite,
                                canRenew: widget.canRenew,
                                canFreeze: widget.canFreeze,
                              ),
                              MembersRosterPagination(
                                visibleCount: rows.length,
                                usingFixtures: false,
                              ),
                            ],
                          ),
                  ),
                ),
                MembersSyncFooter(offline: state.showingCachedOffline),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.onAdd,
    required this.onFilter,
  });

  final VoidCallback? onAdd;
  final VoidCallback onFilter;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stack = constraints.maxWidth < 720;
        final titleBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'members.title'.tr(),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: KineticTokens.pureWhite,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                fontSize: 48,
                height: 1,
                letterSpacing: -1.5,
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Text(
                'members.subtitle'.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFFC4C9AC),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ],
        );

        final actions = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton.icon(
              onPressed: onFilter,
              icon: const Icon(Icons.filter_list, size: 16),
              label: Text('members.cta.filter_type'.tr()),
              style: OutlinedButton.styleFrom(
                foregroundColor: KineticTokens.onSurface,
                backgroundColor: KineticTokens.surfaceContainerHigh,
                side: BorderSide(
                  color: const Color(0xFF444933).withValues(alpha: 0.3),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: onAdd,
              style: FilledButton.styleFrom(
                backgroundColor: KineticTokens.primaryContainer,
                foregroundColor: KineticTokens.onPrimaryContainer,
                disabledBackgroundColor: KineticTokens.primaryContainer
                    .withValues(alpha: 0.4),
                disabledForegroundColor: KineticTokens.onPrimaryContainer
                    .withValues(alpha: 0.6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 1.2,
                ),
              ),
              child: Text('add_member.cta.add_new'.tr()),
            ),
          ],
        );

        if (stack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleBlock,
              const SizedBox(height: 24),
              actions,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: titleBlock),
            actions,
          ],
        );
      },
    );
  }
}

/// Empty live roster — actionable chrome (FEAT-59 AC-A2 / AC-A3).
class _EmptyRosterChrome extends StatelessWidget {
  const _EmptyRosterChrome({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(32, 48, 32, 48),
      child: Column(
        children: [
          Text(
            'members.empty_roster'.tr(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFFC4C9AC),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onRetry,
            child: Text('memberships.retry'.tr()),
          ),
        ],
      ),
    );
  }
}

