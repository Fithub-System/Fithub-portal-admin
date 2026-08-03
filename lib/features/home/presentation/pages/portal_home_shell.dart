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
import '../../../dashboard/presentation/widgets/admin_overview_dashboard.dart';
import '../../../members/presentation/screens/member_management_screen.dart';
import '../../../members/inject_members.dart' as members_di;
import '../../../billing/presentation/screens/marketing_promotions_screen.dart';
import '../../../gym_sku_settings/presentation/screens/gym_sku_settings_screen.dart';
import '../../../staff_invite/presentation/screens/staff_invite_screen.dart';
import '../widgets/access_scanner_focus_host.dart';
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
///
/// FEAT-10 Install I3 — G2 Gym Settings opens from avatar menu or Reports nest
/// (focus overlay). Not a 7th rail tab (AC-D4).
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
  bool _settingsFocus = false;

  void _openScannerFocus() {
    setState(() {
      _selectedIndex = PortalShellDestinations.home;
      _scannerFocus = true;
      _settingsFocus = false;
    });
  }

  void _closeScannerFocus() {
    if (!_scannerFocus) return;
    setState(() => _scannerFocus = false);
  }

  void _openSettingsFocus() {
    setState(() {
      _scannerFocus = false;
      _settingsFocus = true;
    });
  }

  void _closeSettingsFocus() {
    if (!_settingsFocus) return;
    setState(() => _settingsFocus = false);
  }

  void _selectDestination(int index) {
    setState(() {
      _selectedIndex = index;
      if (index != PortalShellDestinations.home) {
        _scannerFocus = false;
      }
      // Settings is nested overlay — closing on rail change keeps IA clear.
      _settingsFocus = false;
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
    final canManageSkuSettings = authState is AuthAuthenticated
        ? authState.profile.canManageSkuSettings
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

            if (_settingsFocus) {
              return Scaffold(
                backgroundColor: KineticTokens.deepCharcoal,
                body: Column(
                  children: [
                    SafeModeBanner(visible: connectivity.isOffline),
                    Expanded(
                      child: BlocProvider(
                        create: (_) =>
                            InjectionContainer.createGymSkuSettingsBloc(),
                        child: GymSkuSettingsScreen(
                          canWrite: canManageSkuSettings,
                          onClose: _closeSettingsFocus,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

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
                ReportsShellPage(onOpenGymSettings: _openSettingsFocus),
              ],
            );

            final content = Column(
              children: [
                _PortalShellHeader(
                  onOpenGymSettings: _openSettingsFocus,
                  onOpenScanner: _openScannerFocus,
                ),
                Expanded(child: body),
              ],
            );

            if (useRail) {
              return Scaffold(
                backgroundColor: KineticTokens.stitchBackground,
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
                            color: Color(0xFF262626),
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

/// Shell chrome: Stitch TopNavBar + language / Gym Settings / sign-out.
///
/// FEAT-16 VF1 region 2 — Admin Console eyebrow, search chrome, QR → scanner,
/// account menu (AC-E1 / FEAT-10 / FEAT-12).
class _PortalShellHeader extends StatelessWidget {
  const _PortalShellHeader({
    required this.onOpenGymSettings,
    required this.onOpenScanner,
  });

  final VoidCallback onOpenGymSettings;
  final VoidCallback onOpenScanner;

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
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: KineticTokens.railSurface.withValues(alpha: 0.92),
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.5),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 64,
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 32),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFF262626)),
            ),
          ),
          child: Row(
            children: [
              Text(
                'home.shell.admin_console'.tr(),
                style: textTheme.labelSmall?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.4,
                  color: KineticTokens.zincGray,
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 256),
                  child: TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'home.shell.search_hint'.tr(),
                      hintStyle: textTheme.bodySmall?.copyWith(
                        fontSize: 13,
                        color: KineticTokens.zincGray,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 18,
                        color: KineticTokens.zincGray,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF171717),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'home.shell.notifications'.tr(),
                onPressed: null,
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFFD4D4D4),
                ),
              ),
              IconButton(
                key: const Key('shell-header-open-scanner'),
                tooltip: 'home.scanner.open_cta'.tr(),
                onPressed: onOpenScanner,
                icon: const Icon(
                  Icons.qr_code_scanner,
                  color: Color(0xFFD4D4D4),
                ),
              ),
              PopupMenuButton<_ShellMenuAction>(
                tooltip: 'home.shell.account_menu'.tr(),
                color: KineticTokens.gunmetalCard,
                onSelected: (action) async {
                  switch (action) {
                    case _ShellMenuAction.localeEn:
                      await _setLocale(context, AppLocales.en);
                    case _ShellMenuAction.localeAr:
                      await _setLocale(context, AppLocales.ar);
                    case _ShellMenuAction.gymSettings:
                      onOpenGymSettings();
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
                    value: _ShellMenuAction.gymSettings,
                    child: Text('home.shell.gym_settings'.tr()),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: _ShellMenuAction.signOut,
                    child: Text('home.shell.sign_out'.tr()),
                  ),
                ],
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.account_circle,
                        color: Color(0xFFD4D4D4),
                      ),
                      const SizedBox(width: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 140),
                        child: Text(
                          name.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelSmall?.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFD4D4D4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _ShellMenuAction { localeEn, localeAr, gymSettings, signOut }

class _PortalNavigationRail extends StatelessWidget {
  const _PortalNavigationRail({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: KineticTokens.railWidth,
      child: Material(
        color: KineticTokens.railSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(32, 32, 32, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'home.shell.brand'.tr(),
                    style: textTheme.titleLarge?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                      color: KineticTokens.electricLime,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'home.shell.brand_subtitle'.tr(),
                    style: textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      color: KineticTokens.zincGray,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: NavigationRail(
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
                backgroundColor: KineticTokens.railSurface,
                extended: true,
                minExtendedWidth: KineticTokens.railWidth,
                indicatorColor: KineticTokens.electricLime.withValues(
                  alpha: 0.12,
                ),
                selectedIconTheme: const IconThemeData(
                  color: KineticTokens.electricLime,
                ),
                unselectedIconTheme: const IconThemeData(
                  color: Color(0xFFA3A3A3),
                ),
                selectedLabelTextStyle: const TextStyle(
                  color: KineticTokens.electricLime,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  letterSpacing: 0.4,
                ),
                unselectedLabelTextStyle: const TextStyle(
                  color: Color(0xFFA3A3A3),
                  fontSize: 12,
                  letterSpacing: 0.4,
                ),
                destinations: [
                  NavigationRailDestination(
                    icon: const Icon(Icons.dashboard_outlined),
                    selectedIcon: const Icon(Icons.dashboard),
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
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.all(24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: null,
                  style: FilledButton.styleFrom(
                    backgroundColor: KineticTokens.primaryContainer,
                    disabledBackgroundColor: KineticTokens.primaryContainer,
                    foregroundColor: KineticTokens.onPrimaryContainer,
                    disabledForegroundColor: KineticTokens.onPrimaryContainer,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    'home.shell.start_workout'.tr(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardDestination extends StatelessWidget {
  const _DashboardDestination({required this.onOpenScanner});

  final VoidCallback onOpenScanner;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, dashboard) {
        final approved =
            dashboard.lastScanMessageKey == 'dashboard.scan.approved';
        final rejected =
            dashboard.lastScanMessageKey == 'dashboard.scan.rejected';

        return ColoredBox(
          color: KineticTokens.stitchBackground,
          child: AdminOverviewDashboard(
            currentOccupancy: dashboard.currentOccupancy,
            capacityLimit: dashboard.capacityLimit,
            onOpenScanner: onOpenScanner,
            statusMessageKey: dashboard.statusMessageKey,
            lastScanApproved: approved,
            lastScanMemberName: dashboard.lastScanMemberName,
            lastScanRejectReason:
                rejected ? dashboard.lastScanRejectReason : null,
          ),
        );
      },
    );
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
