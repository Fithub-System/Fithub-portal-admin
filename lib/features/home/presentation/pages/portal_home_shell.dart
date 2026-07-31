import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/kinetic_tokens.dart';
import '../../../../core/i18n/app_locales.dart';
import '../../../../core/network/supabase_locale_headers.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../connectivity/presentation/cubit/connectivity_cubit.dart';
import '../../../connectivity/presentation/widgets/safe_mode_banner.dart';
import '../../../dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../../dashboard/presentation/widgets/live_occupancy_gauge.dart';
import '../../../members/presentation/screens/member_management_screen.dart';
import '../../../members/inject_members.dart' as members_di;
import '../../../billing/presentation/screens/marketing_promotions_screen.dart';
import '../../../staff_invite/presentation/screens/staff_invite_screen.dart';
import '../widgets/access_scanner_focus_host.dart';
import '../widgets/home_access_scanner_cta.dart';
import '../widgets/kinetic_coming_soon_empty.dart';
import 'portal_shell_destinations.dart';

/// Adaptive Admin shell: NavigationRail (desktop/tablet) / NavigationBar (mobile).
///
/// FEAT-11 Install I1 — Stitch shell IA:
/// Home | Members | Staff | Classes | Marketing | Reports
/// (`@specs/FEAT-11-PORTAL-SHELL-MATCH-STITCH.md` §3).
///
/// FEAT-12 Install I2 — G1 Access Scanner / Check-in Gate mounts under Home
/// (CTA → focus mode). Not a rail destination (AC-A1).
/// Language + sign-out via header avatar menu (AC-E1).
class PortalHomeShell extends StatefulWidget {
  const PortalHomeShell({super.key});

  static const double railBreakpoint = 600;

  @override
  State<PortalHomeShell> createState() => _PortalHomeShellState();
}

class _PortalHomeShellState extends State<PortalHomeShell> {
  int _selectedIndex = PortalShellDestinations.home;
  bool _scannerFocus = false;

  void _openScannerFocus() {
    setState(() {
      _selectedIndex = PortalShellDestinations.home;
      _scannerFocus = true;
    });
  }

  void _closeScannerFocus() {
    if (!_scannerFocus) return;
    setState(() => _scannerFocus = false);
  }

  void _selectDestination(int index) {
    setState(() {
      _selectedIndex = index;
      if (index != PortalShellDestinations.home) {
        _scannerFocus = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.select((AuthBloc b) => b.state);
    final canManageMemberships = authState is AuthAuthenticated
        ? authState.profile.canManageMemberships
        : false;
    final canEnrollMembers = authState is AuthAuthenticated
        ? authState.profile.canEnrollMembers
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

            // Focus mode covers shell body (rail + destinations) so the
            // Check-in Gate is desk-fullscreen; zinc SafeMode stays above.
            if (_scannerFocus) {
              return Scaffold(
                backgroundColor: KineticTokens.deepCharcoal,
                body: Column(
                  children: [
                    SafeModeBanner(visible: connectivity.isOffline),
                    Expanded(
                      child: AccessScannerFocusHost(
                        onClose: _closeScannerFocus,
                      ),
                    ),
                  ],
                ),
              );
            }

            final body = IndexedStack(
              index: _selectedIndex,
              children: [
                _DashboardDestination(onOpenScanner: _openScannerFocus),
                MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (_) =>
                          InjectionContainer.createMembershipsCubit(),
                    ),
                    BlocProvider(
                      create: (_) => members_di.createMemberRosterCubit(
                        getIt: InjectionContainer.locator,
                        tenantId: tenantId,
                      )..load(),
                    ),
                  ],
                  child: MemberManagementScreen(
                    canWrite: canManageMemberships,
                    canEnroll: canEnrollMembers,
                  ),
                ),
                const _StaffDestination(),
                const ClassesComingSoonPage(),
                BlocProvider(
                  create: (_) => InjectionContainer.createBillingCubit(),
                  child: MarketingPromotionsScreen(canWrite: canManageBilling),
                ),
                const ReportsComingSoonPage(),
              ],
            );

            final content = Column(
              children: [
                const _PortalShellHeader(),
                Expanded(child: body),
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
                            onDestinationSelected: _selectDestination,
                          ),
                          const VerticalDivider(
                            width: 1,
                            thickness: 1,
                            color: KineticTokens.zincGray,
                          ),
                          Expanded(child: content),
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
                  Expanded(child: content),
                ],
              ),
              bottomNavigationBar: NavigationBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: _selectDestination,
                backgroundColor: KineticTokens.gunmetalCard,
                indicatorColor: KineticTokens.electricLime.withValues(
                  alpha: 0.2,
                ),
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.home_outlined),
                    selectedIcon: const Icon(
                      Icons.home,
                      color: KineticTokens.electricLime,
                    ),
                    label: 'nav.home'.tr(),
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
                    icon: const Icon(Icons.badge_outlined),
                    selectedIcon: const Icon(
                      Icons.badge,
                      color: KineticTokens.electricLime,
                    ),
                    label: 'nav.staff'.tr(),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.fitness_center_outlined),
                    selectedIcon: const Icon(
                      Icons.fitness_center,
                      color: KineticTokens.electricLime,
                    ),
                    label: 'nav.classes'.tr(),
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
                    icon: const Icon(Icons.insights_outlined),
                    selectedIcon: const Icon(
                      Icons.insights,
                      color: KineticTokens.electricLime,
                    ),
                    label: 'nav.reports'.tr(),
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

/// Shell chrome: language toggle + sign-out (Account rail removed — AC-E1).
class _PortalShellHeader extends StatelessWidget {
  const _PortalShellHeader();

  Future<void> _setLocale(BuildContext context, Locale locale) async {
    await context.setLocale(locale);
    SupabaseLocaleHeaders.apply(locale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.select(
      (AuthBloc b) => b.state is AuthAuthenticated
          ? (b.state as AuthAuthenticated).profile
          : null,
    );
    final name = profile?.name ?? 'home.shell.admin_fallback'.tr();
    final locale = context.locale;

    return Material(
      color: KineticTokens.gunmetalCard,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'home.shell.welcome'.tr(namedArgs: {'name': name}),
                  textAlign: TextAlign.start,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: KineticTokens.pureWhite,
                  ),
                ),
              ),
              PopupMenuButton<_ShellMenuAction>(
                tooltip: 'home.shell.account_menu'.tr(),
                icon: const Icon(
                  Icons.account_circle,
                  color: KineticTokens.electricLime,
                ),
                color: KineticTokens.gunmetalCard,
                onSelected: (action) async {
                  switch (action) {
                    case _ShellMenuAction.localeEn:
                      await _setLocale(context, AppLocales.en);
                    case _ShellMenuAction.localeAr:
                      await _setLocale(context, AppLocales.ar);
                    case _ShellMenuAction.signOut:
                      context.read<AuthBloc>().add(
                        const AuthSignOutRequested(),
                      );
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _ShellMenuAction.localeEn,
                    enabled: locale.languageCode != 'en',
                    child: Text('home.shell.locale_en'.tr()),
                  ),
                  PopupMenuItem(
                    value: _ShellMenuAction.localeAr,
                    enabled: locale.languageCode != 'ar',
                    child: Text('home.shell.locale_ar'.tr()),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: _ShellMenuAction.signOut,
                    child: Text('home.shell.sign_out'.tr()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _ShellMenuAction { localeEn, localeAr, signOut }

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
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: Text('nav.home'.tr()),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.group_outlined),
          selectedIcon: const Icon(Icons.group),
          label: Text('nav.members'.tr()),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.badge_outlined),
          selectedIcon: const Icon(Icons.badge),
          label: Text('nav.staff'.tr()),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.fitness_center_outlined),
          selectedIcon: const Icon(Icons.fitness_center),
          label: Text('nav.classes'.tr()),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.campaign_outlined),
          selectedIcon: const Icon(Icons.campaign),
          label: Text('nav.marketing'.tr()),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.insights_outlined),
          selectedIcon: const Icon(Icons.insights),
          label: Text('nav.reports'.tr()),
        ),
      ],
    );
  }
}

class _DashboardDestination extends StatelessWidget {
  const _DashboardDestination({required this.onOpenScanner});

  final VoidCallback onOpenScanner;

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
                  const SizedBox(height: 24),
                  HomeAccessScannerCta(onOpenScanner: onOpenScanner),
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

/// Staff destination — invite preserved from former Account rail (FEAT-05 / AC-D1).
///
/// Stitch Staff Management `dcc070ef2b1e45058b3e042ad70140e3`.
class _StaffDestination extends StatelessWidget {
  const _StaffDestination();

  static const String stitchScreenId = 'dcc070ef2b1e45058b3e042ad70140e3';

  @override
  Widget build(BuildContext context) {
    final profile = context.select(
      (AuthBloc b) => b.state is AuthAuthenticated
          ? (b.state as AuthAuthenticated).profile
          : null,
    );
    final textTheme = Theme.of(context).textTheme;
    final canInvite = profile?.canInviteStaff ?? false;

    return ListView(
      padding: const EdgeInsetsDirectional.all(24),
      children: [
        Text(
          'staff.shell.title'.tr(),
          textAlign: TextAlign.start,
          style: textTheme.titleLarge?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: KineticTokens.pureWhite,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'staff.shell.subtitle'.tr(),
          textAlign: TextAlign.start,
          style: textTheme.bodyMedium?.copyWith(
            fontSize: 13,
            color: KineticTokens.zincGray,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'home.coming_soon.stitch_ref'.tr(
            namedArgs: {'id': stitchScreenId},
          ),
          textAlign: TextAlign.start,
          style: textTheme.labelSmall?.copyWith(
            fontSize: 10,
            color: KineticTokens.zincGray.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 24),
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
