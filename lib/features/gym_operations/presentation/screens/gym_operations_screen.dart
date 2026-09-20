import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/kinetic_tokens.dart';
import '../../../gym_onboarding/presentation/widgets/stitch_kinetic_chrome.dart';
import '../scanner_input_cubit.dart';

/// FEAT-97 Settings → Operations — Stitch `aa6f5bb356214f67b22ab8e840f12d96`.
class GymOperationsScreen extends StatelessWidget {
  const GymOperationsScreen({super.key});

  static const String stitchScreenIdEn = 'aa6f5bb356214f67b22ab8e840f12d96';
  static const String stitchScreenIdAr = 'a718b3ad19fd4640adf2ceebc77ddf1f';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ScannerInputCubit>().state;
    return ColoredBox(
      color: KineticTokens.deepCharcoal,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: StitchKineticCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: StitchStageBadge(
                        label: 'settings.operations.eyebrow'.tr(),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: KineticTokens.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'settings.operations.admin_only'.tr().toUpperCase(),
                        style: TextStyle(
                          color: KineticTokens.electricLime,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'settings.operations.title'.tr(),
                  style: TextStyle(
                    color: KineticTokens.pureWhite,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'settings.operations.subtitle'.tr(),
                  style: TextStyle(color: KineticTokens.zincGray, fontSize: 13),
                ),
                StitchSectionLabel(
                  label: 'settings.operations.mode_section'.tr(),
                ),
                _ModeCard(
                  mode: ScannerInputMode.hardwareGun,
                  selected: state.draft == ScannerInputMode.hardwareGun,
                  recommended: true,
                ),
                const SizedBox(height: 10),
                _ModeCard(
                  mode: ScannerInputMode.webcam,
                  selected: state.draft == ScannerInputMode.webcam,
                ),
                const SizedBox(height: 10),
                _ModeCard(
                  mode: ScannerInputMode.hybrid,
                  selected: state.draft == ScannerInputMode.hybrid,
                  isDefault: true,
                ),
                const SizedBox(height: 16),
                Text(
                  'settings.operations.helper'.tr(),
                  style: TextStyle(
                    color: KineticTokens.zincGray,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                if (state.saveError != null) ...[
                  Text(
                    state.saveError!.tr(),
                    style: StitchKineticChrome.text(
                      context,
                      color: KineticTokens.peakCoral,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: SizedBox(
                    width: 220,
                    child: StitchLimeCta(
                      label: 'settings.operations.save'.tr(),
                      busy: state.saving,
                      enabled: state.canWrite,
                      showArrow: false,
                      onTap: () => context.read<ScannerInputCubit>().save(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.mode,
    required this.selected,
    this.recommended = false,
    this.isDefault = false,
  });

  final ScannerInputMode mode;
  final bool selected;
  final bool recommended;
  final bool isDefault;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ScannerInputCubit>();
    return Material(
      color: selected
          ? KineticTokens.electricLime.withValues(alpha: 0.08)
          : KineticTokens.deepCharcoal,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        key: Key('scanner-mode-${mode.wire}'),
        onTap: cubit.state.canWrite ? () => cubit.selectDraft(mode) : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? KineticTokens.electricLime
                  : KineticTokens.surfaceContainerHigh,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected
                    ? KineticTokens.electricLime
                    : KineticTokens.zincGray,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'settings.operations.modes.${mode.wire}.title'.tr(),
                          style: TextStyle(
                            color: KineticTokens.pureWhite,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        if (recommended)
                          _pill(
                            'settings.operations.recommended'.tr(),
                            KineticTokens.electricLime,
                          ),
                        if (isDefault)
                          _pill(
                            'settings.operations.default_badge'.tr(),
                            KineticTokens.electricLime,
                          ),
                        if (mode == ScannerInputMode.hardwareGun)
                          _pill(
                            'settings.operations.latency'.tr(),
                            KineticTokens.surfaceContainerHigh,
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'settings.operations.modes.${mode.wire}.body'.tr(),
                      style: TextStyle(
                        color: KineticTokens.zincGray,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(String label, Color bg) {
    final onLime = bg == KineticTokens.electricLime;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: onLime ? KineticTokens.electricLime : bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: onLime ? KineticTokens.deepCharcoal : KineticTokens.onSurface,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
