import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/kinetic_tokens.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../connectivity/presentation/cubit/connectivity_cubit.dart';
import '../../../connectivity/presentation/widgets/safe_mode_banner.dart';
import '../../../dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../../dashboard/presentation/widgets/live_occupancy_gauge.dart';
import '../../../access_scanner/presentation/screens/access_scanner_screen.dart';
import '../../../members/presentation/screens/member_management_screen.dart';
import '../../../members/inject_members.dart' as members_di;
import '../../../billing/presentation/screens/marketing_promotions_screen.dart';
import '../../../staff_invite/presentation/screens/staff_invite_screen.dart';
import 'portal_shell_destinations.dart';

/// Adaptive Admin shell: NavigationRail (desktop/tablet) / NavigationBar (mobile).
class PortalHomeShell extends StatefulWidget {
  const PortalHomeShell({super.key});

  static const double railBreakpoint = 600;

  @override
  State<PortalHomeShell> createState() => _PortalHomeShellState();
}

class _PortalHomeShellState extends State<PortalHomeShell> {
  int _selectedIndex = PortalShellDestinations.dashboard;

  @override
  Widget build(BuildContext context) {
    final authState = context.select((AuthBloc b) => b.state);
    final canManageMemberships = authState is AuthAuthenticated
        ? authState.profile.canManageMemberships
        : false;
    final canManageBilling = authState is AuthAuthenticated
        ? authState.profile.canManageBilling
        : false;
    final tenantId = authState is AuthAuthenticated
        ? authState.profile.tenantId
        : '';

    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, connectivity) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final useRail =
                constraints.maxWidth >= PortalHomeShell.railBreakpoint;

            final body = IndexedStack(
              index: _selectedIndex,
              children: [
                const _DashboardDestination(),
                const AccessScannerScreen(),
                MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (_) => InjectionContainer.createMembershipsCubit(),
                    ),
                    BlocProvider(
                      create: (_) =>
                          members_di.createMemberRosterCubit(
                            getIt: InjectionContainer.locator,
                            tenantId: tenantId,
                          )..load(),
                    ),
                  ],
                  child: MemberManagementScreen(
                    canWrite: canManageMemberships,
                  ),
                ),
                BlocProvider(
                  create: (_) => InjectionContainer.createBillingCubit(),
                  child: MarketingPromotionsScreen(canWrite: canManageBilling),
                ),
                const _AccountDestination(),
              ],
            );

            if (useRail) {
              return Scaffold(
                backgroundColor: KineticTokens.deepCharcoal,
                body: Column(
                  children: [
                    SafeModeBanner(visible: connectivity.isOffline),
                    Expanded(
                      child: Row(
                        children: [
                          _PortalNavigationRail(
                            selectedIndex: _selectedIndex,
                            onDestinationSelected: (i) {
                              setState(() => _selectedIndex = i);
                            },
                          ),
                          const VerticalDivider(
                            width: 1,
                            thickness: 1,
                            color: KineticTokens.zincGray,
                          ),
                          Expanded(child: body),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            return Scaffold(
              backgroundColor: KineticTokens.deepCharcoal,
              body: Column(
                children: [
                  SafeModeBanner(visible: connectivity.isOffline),
                  Expanded(child: body),
                ],
              ),
              bottomNavigationBar: NavigationBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (i) {
                  setState(() => _selectedIndex = i);
                },
                backgroundColor: KineticTokens.gunmetalCard,
                indicatorColor: KineticTokens.electricLime.withValues(
                  alpha: 0.2,
                ),
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.dashboard_outlined),
                    selectedIcon: const Icon(
                      Icons.dashboard,
                      color: KineticTokens.electricLime,
                    ),
                    label: 'nav.dashboard'.tr(),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.qr_code_scanner_outlined),
                    selectedIcon: const Icon(
                      Icons.qr_code_scanner,
                      color: KineticTokens.electricLime,
                    ),
                    label: 'nav.scan'.tr(),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.group_outlined),
                    selectedIcon: const Icon(
                      Icons.group,
                      color: KineticTokens.electricLime,
                    ),
                    label: 'nav.members'.tr(),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.campaign_outlined),
                    selectedIcon: const Icon(
                      Icons.campaign,
                      color: KineticTokens.electricLime,
                    ),
                    label: 'nav.marketing'.tr(),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.person_outline),
                    selectedIcon: const Icon(
                      Icons.person,
                      color: KineticTokens.electricLime,
                    ),
                    label: 'nav.account'.tr(),
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

class _PortalNavigationRail extends StatelessWidget {
  const _PortalNavigationRail({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      backgroundColor: KineticTokens.gunmetalCard,
      indicatorColor: KineticTokens.electricLime.withValues(alpha: 0.2),
      selectedIconTheme: const IconThemeData(color: KineticTokens.electricLime),
      unselectedIconTheme: const IconThemeData(color: KineticTokens.zincGray),
      selectedLabelTextStyle: const TextStyle(
        color: KineticTokens.electricLime,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      unselectedLabelTextStyle: const TextStyle(
        color: KineticTokens.zincGray,
        fontSize: 12,
      ),
      labelType: NavigationRailLabelType.all,
      destinations: [
        NavigationRailDestination(
          icon: const Icon(Icons.dashboard_outlined),
          selectedIcon: const Icon(Icons.dashboard),
          label: Text('nav.dashboard'.tr()),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.qr_code_scanner_outlined),
          selectedIcon: const Icon(Icons.qr_code_scanner),
          label: Text('nav.scan'.tr()),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.group_outlined),
          selectedIcon: const Icon(Icons.group),
          label: Text('nav.members'.tr()),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.campaign_outlined),
          selectedIcon: const Icon(Icons.campaign),
          label: Text('nav.marketing'.tr()),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.person_outline),
          selectedIcon: const Icon(Icons.person),
          label: Text('nav.account'.tr()),
        ),
      ],
    );
  }
}

class _DashboardDestination extends StatelessWidget {
  const _DashboardDestination();

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

            return SingleChildScrollView(
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
                  if (dashboard.statusMessageKey != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      dashboard.statusMessageKey!.tr(),
                      textAlign: TextAlign.start,
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: KineticTokens.electricLime,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  LiveOccupancyGauge(
                    current: dashboard.currentOccupancy,
                    capacity: dashboard.capacityLimit,
                  ),
                  if (dashboard.lastScanMessageKey != null) ...[
                    const SizedBox(height: 24),
                    Text(
                      _scanMessage(dashboard),
                      textAlign: TextAlign.start,
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                        color: KineticTokens.electricLime,
                      ),
                    ),
                  ],
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

class _AccountDestination extends StatelessWidget {
  const _AccountDestination();

  @override
  Widget build(BuildContext context) {
    final profile = context.select(
      (AuthBloc b) => b.state is AuthAuthenticated
          ? (b.state as AuthAuthenticated).profile
          : null,
    );
    final dash = 'home.shell.em_dash'.tr();
    final name = profile?.name ?? 'home.shell.admin_fallback'.tr();
    final textTheme = Theme.of(context).textTheme;
    final canInvite = profile?.canInviteStaff ?? false;

    return ListView(
      padding: const EdgeInsetsDirectional.all(24),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'home.shell.welcome'.tr(namedArgs: {'name': name}),
                textAlign: TextAlign.start,
                style: textTheme.titleLarge?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: KineticTokens.pureWhite,
                ),
              ),
            ),
            IconButton(
              tooltip: 'home.shell.sign_out'.tr(),
              onPressed: () =>
                  context.read<AuthBloc>().add(const AuthSignOutRequested()),
              icon: const Icon(Icons.logout, color: KineticTokens.zincGray),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'home.shell.command_center'.tr(),
          textAlign: TextAlign.start,
          style: textTheme.labelLarge?.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: KineticTokens.zincGray,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'home.shell.role'.tr(namedArgs: {'role': profile?.role ?? dash}),
          textAlign: TextAlign.start,
          style: textTheme.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: KineticTokens.electricLime,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'home.shell.tenant'.tr(
            namedArgs: {'tenant': profile?.tenantId ?? dash},
          ),
          textAlign: TextAlign.start,
          style: textTheme.bodyMedium?.copyWith(
            fontSize: 13,
            color: KineticTokens.zincGray,
          ),
        ),
        const SizedBox(height: 32),
        if (canInvite)
          BlocProvider(
            create: (_) => InjectionContainer.createStaffInviteBloc(),
            child: const StaffInviteScreen(),
          )
        else
          const StaffInviteDeniedView(),
      ],
    );
  }
}
