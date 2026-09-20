import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/kinetic_tokens.dart';
import '../../../../injection_container.dart';
import '../../../gym_onboarding/presentation/screens/gym_onboarding_wizard_page.dart';
import '../../../gym_onboarding/presentation/widgets/stitch_kinetic_chrome.dart';
import '../../../gym_operations/presentation/screens/gym_operations_screen.dart';
import '../../../gym_sku_settings/presentation/screens/gym_sku_settings_screen.dart';
import '../../../memberships/presentation/widgets/freeze_policy_settings_section.dart';

/// Settings hub — Stitch nest SKU · Freeze · Gym Profile · Operations.
///
/// Not a 7th rail. Pills match FEAT-97 Operations artboard.
class PortalSettingsHubScreen extends StatefulWidget {
  const PortalSettingsHubScreen({super.key, required this.canWriteSku});

  final bool canWriteSku;

  @override
  State<PortalSettingsHubScreen> createState() =>
      _PortalSettingsHubScreenState();
}

class _PortalSettingsHubScreenState extends State<PortalSettingsHubScreen> {
  String _module = 'profile';

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: KineticTokens.deepCharcoal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'settings.hub.title'.tr(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: KineticTokens.electricLime,
                  ),
                ),
                const SizedBox(height: 8),
                StitchSettingsPills(
                  selected: _module,
                  onSelect: (id) => setState(() => _module = id),
                ),
              ],
            ),
          ),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _body() {
    return switch (_module) {
      'sku' => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => InjectionContainer.createGymSkuSettingsBloc(),
          ),
        ],
        child: GymSkuSettingsScreen(
          canWrite: widget.canWriteSku,
          includeFreezePolicy: false,
          onClose: () => setState(() => _module = 'profile'),
        ),
      ),
      'freeze' => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => InjectionContainer.createMembershipsCubit(),
          ),
        ],
        child: _FreezePolicyModuleScreen(
          canWrite: widget.canWriteSku,
          onClose: () => setState(() => _module = 'profile'),
        ),
      ),
      'operations' => const GymOperationsScreen(),
      _ => BlocProvider(
        create: (_) => InjectionContainer.createGymOnboardingCubit()..load(),
        child: GymOnboardingWizardPage(onClose: () {}),
      ),
    };
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
    return ColoredBox(
      color: KineticTokens.deepCharcoal,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: onClose,
              child: Text('settings.hub.back'.tr()),
            ),
          ),
          FreezePolicySettingsSection(canWrite: canWrite),
        ],
      ),
    );
  }
}
