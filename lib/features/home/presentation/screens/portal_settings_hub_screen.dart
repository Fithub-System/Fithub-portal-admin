import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/kinetic_tokens.dart';
import '../../../../injection_container.dart';
import '../../../gym_sku_settings/presentation/screens/gym_sku_settings_screen.dart';
import '../../../memberships/presentation/widgets/freeze_policy_settings_section.dart';

/// Settings rail hub — module ListTiles (owner soft lock 2026-09-08).
///
/// Modules: SKU & Marketplace · Freeze policy.
class PortalSettingsHubScreen extends StatefulWidget {
  const PortalSettingsHubScreen({
    super.key,
    required this.canWriteSku,
  });

  final bool canWriteSku;

  @override
  State<PortalSettingsHubScreen> createState() =>
      _PortalSettingsHubScreenState();
}

enum _SettingsModule { hub, sku, freeze }

class _PortalSettingsHubScreenState extends State<PortalSettingsHubScreen> {
  _SettingsModule _module = _SettingsModule.hub;

  void _open(_SettingsModule module) => setState(() => _module = module);

  void _backToHub() => setState(() => _module = _SettingsModule.hub);

  @override
  Widget build(BuildContext context) {
    return switch (_module) {
      _SettingsModule.hub => _SettingsModuleList(
          onOpenSku: () => _open(_SettingsModule.sku),
          onOpenFreeze: () => _open(_SettingsModule.freeze),
        ),
      _SettingsModule.sku => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => InjectionContainer.createGymSkuSettingsBloc(),
            ),
          ],
          child: GymSkuSettingsScreen(
            canWrite: widget.canWriteSku,
            includeFreezePolicy: false,
            onClose: _backToHub,
          ),
        ),
      _SettingsModule.freeze => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => InjectionContainer.createMembershipsCubit(),
            ),
          ],
          child: _FreezePolicyModuleScreen(
            canWrite: widget.canWriteSku,
            onClose: _backToHub,
          ),
        ),
    };
  }
}

class _SettingsModuleList extends StatelessWidget {
  const _SettingsModuleList({
    required this.onOpenSku,
    required this.onOpenFreeze,
  });

  final VoidCallback onOpenSku;
  final VoidCallback onOpenFreeze;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ColoredBox(
      color: KineticTokens.deepCharcoal,
      child: ListView(
        padding: const EdgeInsetsDirectional.all(24),
        children: [
          Text(
            'settings.hub.title'.tr(),
            style: textTheme.headlineMedium?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: KineticTokens.electricLime,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'settings.hub.subtitle'.tr(),
            style: textTheme.bodyMedium?.copyWith(
              color: KineticTokens.zincGray,
            ),
          ),
          const SizedBox(height: 24),
          _SettingsModuleTile(
            icon: Icons.cloud_outlined,
            titleKey: 'settings.hub.modules.sku.title',
            bodyKey: 'settings.hub.modules.sku.body',
            onTap: onOpenSku,
          ),
          const SizedBox(height: 12),
          _SettingsModuleTile(
            icon: Icons.ac_unit_outlined,
            titleKey: 'settings.hub.modules.freeze.title',
            bodyKey: 'settings.hub.modules.freeze.body',
            onTap: onOpenFreeze,
          ),
        ],
      ),
    );
  }
}

class _SettingsModuleTile extends StatelessWidget {
  const _SettingsModuleTile({
    required this.icon,
    required this.titleKey,
    required this.bodyKey,
    required this.onTap,
  });

  final IconData icon;
  final String titleKey;
  final String bodyKey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: KineticTokens.surfaceContainerLow,
      borderRadius: BorderRadius.circular(KineticTokens.dashboardCardRadius),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            KineticTokens.dashboardCardRadius,
          ),
        ),
        leading: Icon(icon, color: KineticTokens.electricLime),
        title: Text(
          titleKey.tr(),
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: KineticTokens.pureWhite,
          ),
        ),
        subtitle: Text(
          bodyKey.tr(),
          style: textTheme.bodySmall?.copyWith(
            color: KineticTokens.zincGray,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: KineticTokens.zincGray,
        ),
      ),
    );
  }
}

class _FreezePolicyModuleScreen extends StatelessWidget {
  const _FreezePolicyModuleScreen({
    required this.canWrite,
    required this.onClose,
  });

  final bool canWrite;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ColoredBox(
      color: KineticTokens.deepCharcoal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: KineticTokens.gunmetalCard,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'settings.hub.back'.tr(),
                      onPressed: onClose,
                      icon: const Icon(
                        Icons.arrow_back,
                        color: KineticTokens.electricLime,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'settings.hub.modules.freeze.title'.tr(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: KineticTokens.pureWhite,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsetsDirectional.all(24),
              children: [
                FreezePolicySettingsSection(canWrite: canWrite),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
