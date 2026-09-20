import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/kinetic_tokens.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../staff_invite/domain/entities/staff_role.dart';
import '../../data/gym_onboarding_remote.dart';
import '../gym_onboarding_cubit.dart';
import '../widgets/stitch_kinetic_chrome.dart';

/// FEAT-96 onboarding wizard — Stitch step ids in FSD §3.
class GymOnboardingWizardPage extends StatelessWidget {
  const GymOnboardingWizardPage({super.key, this.onClose});

  /// When set (Settings Profile), Finish later returns to the hub.
  final VoidCallback? onClose;

  static const String stitchStep1En = '89e695b4c4bc4a8d8319bcf9afcc8ac5';
  static const String stitchStep2En = '9dfae0b2f71f40299c24671b43fe4813';
  static const String stitchStep3En = '7ddcc18394434ed78dc229e2adb6dc98';
  static const String stitchStep4En = 'f3635eacecce40c385c0b335c371a0bb';
  static const String stitchStep5En = 'a5827af544e540b7a7890da089327b2a';
  static const String stitchProfileEn = '28a6e5e325164b70a9a139f4599832c4';
  static const double formMaxWidth = StitchKineticChrome.formMaxWidth;

  @override
  Widget build(BuildContext context) {
    return BlocListener<GymOnboardingCubit, GymOnboardingState>(
      listenWhen: (p, n) =>
          n.messageKey != null && n.messageKey != p.messageKey,
      listener: (context, state) {
        final key = state.messageKey;
        if (key == null) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(key.tr())));
      },
      child: Scaffold(
        backgroundColor: KineticTokens.deepCharcoal,
        body: SafeArea(child: _WizardBody(onClose: onClose)),
      ),
    );
  }
}

class _WizardBody extends StatelessWidget {
  const _WizardBody({this.onClose});

  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GymOnboardingCubit>().state;
    if (state.loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: KineticTokens.electricLime),
            const SizedBox(height: 16),
            Text(
              'onboarding.loading'.tr(),
              style: const TextStyle(color: KineticTokens.zincGray),
            ),
          ],
        ),
      );
    }
    if (state.snapshot == null && state.messageKey == 'onboarding.error.load') {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'onboarding.error.load'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: KineticTokens.pureWhite),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.read<GymOnboardingCubit>().load(),
                child: Text('onboarding.retry'.tr()),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        StitchPulseTopBar(
          trailing: TextButton(
            onPressed: () {
              final close = onClose;
              if (close != null) {
                close();
                return;
              }
              context.read<AuthBloc>().add(const AuthOnboardingDeferred());
            },
            style: TextButton.styleFrom(
              foregroundColor: KineticTokens.electricLime,
            ),
            child: Text(
              'onboarding.finish_later'.tr().toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                fontSize: 12,
              ),
            ),
          ),
        ),
        StitchConnectedStepper(
          step: state.step,
          labels: [
            'onboarding.steps.brand'.tr(),
            'onboarding.steps.branches'.tr(),
            'onboarding.steps.staff'.tr(),
            'onboarding.steps.plans'.tr(),
            'onboarding.steps.publish'.tr(),
          ],
          onStepTap: (i) => context.read<GymOnboardingCubit>().setStep(i),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: Center(
              child: StitchKineticCard(
                child: switch (state.step) {
                  0 => const _BrandStep(),
                  1 => const _BranchStep(),
                  2 => const _StaffStep(),
                  3 => const _PlanStep(),
                  _ => const _ReviewStep(),
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Widget _stepHeader({required String stage, required String title}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      StitchStageBadge(label: stage),
      const SizedBox(height: 10),
      Text(
        title,
        style: const TextStyle(
          color: KineticTokens.pureWhite,
          fontSize: 28,
          fontWeight: FontWeight.w900,
          height: 1.1,
          letterSpacing: -0.4,
        ),
      ),
      const SizedBox(height: 16),
    ],
  );
}

class _BrandStep extends StatelessWidget {
  const _BrandStep();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GymOnboardingCubit>();
    final s = context.watch<GymOnboardingCubit>().state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _stepHeader(
          stage: 'onboarding.step1.stage'.tr(),
          title: 'onboarding.step1.title'.tr(),
        ),
        StitchSectionLabel(label: 'onboarding.step1.media'.tr()),
        Row(
          children: [
            const Expanded(
              child: StitchDashedUpload(label: 'Logo', compact: true),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: StitchDashedUpload(label: 'onboarding.step1.banner'.tr()),
            ),
          ],
        ),
        StitchSectionLabel(label: 'onboarding.step1.entity'.tr()),
        _BoundField(
          value: s.brandName,
          label: 'onboarding.step1.brand'.tr(),
          hint: 'onboarding.register.trading_hint'.tr(),
          onChanged: (v) => cubit.patch(s.copyWith(brandName: v)),
        ),
        _BoundField(
          value: s.tradingName,
          label: 'onboarding.step1.trading'.tr(),
          hint: 'onboarding.register.trading_hint'.tr(),
          onChanged: (v) => cubit.patch(s.copyWith(tradingName: v)),
        ),
        _BoundField(
          value: s.taxId,
          label: 'onboarding.step1.tax'.tr(),
          onChanged: (v) => cubit.patch(s.copyWith(taxId: v)),
        ),
        _BoundField(
          value: s.contactName,
          label: 'onboarding.step1.contact'.tr(),
          onChanged: (v) => cubit.patch(s.copyWith(contactName: v)),
        ),
        _BoundField(
          value: s.contactPhone,
          label: 'onboarding.step1.phone'.tr(),
          keyboardType: TextInputType.phone,
          onChanged: (v) => cubit.patch(s.copyWith(contactPhone: v)),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: _LimeButton(
            label: 'onboarding.next_branches'.tr(),
            busy: s.saving,
            onTap: () => cubit.saveBrand(),
          ),
        ),
      ],
    );
  }
}

class _BranchStep extends StatelessWidget {
  const _BranchStep();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GymOnboardingCubit>();
    final s = context.watch<GymOnboardingCubit>().state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _stepHeader(
          stage: 'onboarding.step2.stage'.tr(),
          title: 'onboarding.step2.title'.tr(),
        ),
        _BoundField(
          value: s.branchName,
          label: 'onboarding.step2.name'.tr(),
          onChanged: (v) => cubit.patch(s.copyWith(branchName: v)),
        ),
        _BoundField(
          value: s.branchAddress,
          label: 'onboarding.step2.address'.tr(),
          onChanged: (v) => cubit.patch(s.copyWith(branchAddress: v)),
        ),
        _BoundField(
          value: s.lat == null ? '' : '${s.lat}',
          label: 'onboarding.step2.lat'.tr(),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (v) => cubit.patch(
            s.copyWith(lat: v.trim().isEmpty ? null : double.tryParse(v)),
          ),
        ),
        _BoundField(
          value: s.lng == null ? '' : '${s.lng}',
          label: 'onboarding.step2.lng'.tr(),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (v) => cubit.patch(
            s.copyWith(lng: v.trim().isEmpty ? null : double.tryParse(v)),
          ),
        ),
        _BoundField(
          value: s.hoursOpen,
          label: 'onboarding.step2.open'.tr(),
          onChanged: (v) => cubit.patch(s.copyWith(hoursOpen: v)),
        ),
        _BoundField(
          value: s.hoursClose,
          label: 'onboarding.step2.close'.tr(),
          onChanged: (v) => cubit.patch(s.copyWith(hoursClose: v)),
        ),
        _BoundField(
          value: s.capacity == null ? '' : '${s.capacity}',
          label: 'onboarding.step2.capacity'.tr(),
          keyboardType: TextInputType.number,
          onChanged: (v) => cubit.patch(
            s.copyWith(capacity: v.trim().isEmpty ? null : int.tryParse(v)),
          ),
        ),
        _BoundField(
          value: s.photoUrl,
          label: 'onboarding.step2.photo_url'.tr(),
          onChanged: (v) => cubit.patch(s.copyWith(photoUrl: v)),
        ),
        const SizedBox(height: 12),
        StitchDashedUpload(label: 'onboarding.step2.photo_url'.tr()),
        const SizedBox(height: 12),
        Text(
          'onboarding.step2.facilities'.tr(),
          style: const TextStyle(
            color: KineticTokens.pureWhite,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tag in GymOnboardingRemote.amenityTags)
              FilterChip(
                key: Key('amenity-$tag'),
                label: Text('onboarding.step2.amenities.$tag'.tr()),
                selected: s.amenityTags.contains(tag),
                selectedColor: KineticTokens.electricLime,
                checkmarkColor: KineticTokens.deepCharcoal,
                labelStyle: TextStyle(
                  color: s.amenityTags.contains(tag)
                      ? KineticTokens.deepCharcoal
                      : KineticTokens.pureWhite,
                ),
                onSelected: (on) {
                  final next = [...s.amenityTags];
                  if (on) {
                    next.add(tag);
                  } else {
                    next.remove(tag);
                  }
                  cubit.patch(s.copyWith(amenityTags: next));
                },
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'onboarding.step2.photo_hint'.tr(),
          style: const TextStyle(color: KineticTokens.zincGray, fontSize: 12),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            StitchGhostButton(
              label: 'onboarding.back'.tr(),
              onTap: () => cubit.setStep(0),
            ),
            const Spacer(),
            _LimeButton(
              label: 'onboarding.next_staff'.tr(),
              busy: s.saving,
              onTap: () => cubit.saveBranch(),
            ),
          ],
        ),
      ],
    );
  }
}

class _StaffStep extends StatefulWidget {
  const _StaffStep();

  @override
  State<_StaffStep> createState() => _StaffStepState();
}

class _StaffStepState extends State<_StaffStep> {
  final email = TextEditingController();
  final name = TextEditingController();

  @override
  void dispose() {
    email.dispose();
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GymOnboardingCubit>();
    final s = context.watch<GymOnboardingCubit>().state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _stepHeader(
          stage: 'onboarding.step3.stage'.tr(),
          title: 'onboarding.step3.title'.tr(),
        ),
        Text(
          'onboarding.step3.honesty'.tr(),
          style: const TextStyle(color: KineticTokens.zincGray),
        ),
        const SizedBox(height: 12),
        StitchFilledField(
          controller: email,
          label: 'onboarding.step3.email'.tr(),
        ),
        StitchFilledField(
          controller: name,
          label: 'onboarding.step3.name'.tr(),
        ),
        const SizedBox(height: 4),
        OutlinedButton(
          onPressed: s.saving
              ? null
              : () => cubit.inviteStaff(
                  email: email.text,
                  name: name.text,
                  role: StaffRole.receptionist,
                ),
          style: OutlinedButton.styleFrom(
            foregroundColor: KineticTokens.electricLime,
            side: const BorderSide(color: KineticTokens.electricLime),
          ),
          child: Text('onboarding.step3.invite_desk'.tr()),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            StitchGhostButton(
              label: 'onboarding.back'.tr(),
              onTap: () => cubit.setStep(1),
            ),
            const Spacer(),
            _LimeButton(
              label: 'onboarding.next_plans'.tr(),
              busy: s.saving,
              onTap: cubit.skipStaff,
            ),
          ],
        ),
      ],
    );
  }
}

class _PlanStep extends StatelessWidget {
  const _PlanStep();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GymOnboardingCubit>();
    final s = context.watch<GymOnboardingCubit>().state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _stepHeader(
          stage: 'onboarding.step4.stage'.tr(),
          title: 'onboarding.step4.title'.tr(),
        ),
        if (s.savedPlans.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'onboarding.step4.saved'.tr(),
            style: const TextStyle(
              color: KineticTokens.zincGray,
              fontWeight: FontWeight.w700,
            ),
          ),
          for (final plan in s.savedPlans)
            ListTile(
              key: Key('saved-plan-${plan.id}'),
              contentPadding: EdgeInsets.zero,
              title: Text(
                plan.name,
                style: const TextStyle(color: KineticTokens.pureWhite),
              ),
              subtitle: Text(
                'onboarding.step4.saved_meta'.tr(
                  namedArgs: {
                    'days': '${plan.durationDays}',
                    'price': '${plan.priceCents ~/ 100}',
                  },
                ),
                style: const TextStyle(color: KineticTokens.zincGray),
              ),
            ),
        ],
        _BoundField(
          value: s.planName,
          label: 'onboarding.step4.name'.tr(),
          onChanged: (v) => cubit.patch(s.copyWith(planName: v)),
        ),
        _BoundField(
          value: s.planDays == null ? '' : '${s.planDays}',
          label: 'onboarding.step4.days'.tr(),
          keyboardType: TextInputType.number,
          onChanged: (v) => cubit.patch(
            s.copyWith(planDays: v.trim().isEmpty ? null : int.tryParse(v)),
          ),
        ),
        _BoundField(
          value: s.planPriceEgp == null ? '' : '${s.planPriceEgp}',
          label: 'onboarding.step4.price'.tr(),
          keyboardType: TextInputType.number,
          onChanged: (v) => cubit.patch(
            s.copyWith(planPriceEgp: v.trim().isEmpty ? null : int.tryParse(v)),
          ),
        ),
        SwitchListTile(
          title: Text(
            'onboarding.step4.roaming'.tr(),
            style: const TextStyle(color: KineticTokens.pureWhite),
          ),
          value: s.passRoaming,
          activeThumbColor: KineticTokens.electricLime,
          onChanged: (v) => cubit.patch(s.copyWith(passRoaming: v)),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          key: const Key('onboarding-add-plan'),
          onPressed: s.saving ? null : () => cubit.savePlan(),
          style: OutlinedButton.styleFrom(
            foregroundColor: KineticTokens.electricLime,
            side: const BorderSide(color: KineticTokens.electricLime),
          ),
          child: Text('onboarding.step4.add_another'.tr().toUpperCase()),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            StitchGhostButton(
              label: 'onboarding.back'.tr(),
              onTap: () => cubit.setStep(2),
            ),
            const Spacer(),
            _LimeButton(
              label: 'onboarding.next_review'.tr(),
              busy: s.saving,
              onTap: () => cubit.continueToReview(),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GymOnboardingCubit>();
    final s = context.watch<GymOnboardingCubit>().state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _stepHeader(
          stage: 'onboarding.step5.stage'.tr(),
          title: 'onboarding.step5.title'.tr(),
        ),
        const SizedBox(height: 8),
        CircleAvatar(
          radius: 48,
          backgroundColor: KineticTokens.gunmetalCard,
          child: Text(
            '${s.score}%',
            style: const TextStyle(
              color: KineticTokens.electricLime,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 16),
        for (final c in s.snapshot?.checks ?? [])
          ListTile(
            leading: Icon(
              c['pass'] == true ? Icons.check_circle : Icons.cancel,
              color: c['pass'] == true
                  ? KineticTokens.electricLime
                  : KineticTokens.peakCoral,
            ),
            title: Text(
              'onboarding.check.${c['id']}'.tr(),
              style: const TextStyle(color: KineticTokens.pureWhite),
            ),
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            StitchGhostButton(
              label: 'onboarding.back'.tr(),
              onTap: () => cubit.setStep(3),
            ),
            const Spacer(),
            _LimeButton(
              label: 'onboarding.publish.cta'.tr(),
              busy: s.saving,
              enabled: s.canPublish,
              onTap: () async {
                final ok = await cubit.publish();
                if (ok && context.mounted) {
                  context.read<AuthBloc>().add(
                    const AuthProfileRefreshRequested(),
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _LimeButton extends StatelessWidget {
  const _LimeButton({
    required this.label,
    required this.onTap,
    this.busy = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onTap;
  final bool busy;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return StitchLimeCta(
      label: label,
      onTap: onTap,
      busy: busy,
      enabled: enabled,
    );
  }
}

class _BoundField extends StatefulWidget {
  const _BoundField({
    required this.value,
    required this.label,
    required this.onChanged,
    this.hint,
    this.keyboardType,
  });

  final String value;
  final String label;
  final String? hint;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;

  @override
  State<_BoundField> createState() => _BoundFieldState();
}

class _BoundFieldState extends State<_BoundField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _BoundField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && _controller.text != widget.value) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: const TextStyle(
              color: KineticTokens.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _controller,
            keyboardType: widget.keyboardType,
            style: const TextStyle(
              color: KineticTokens.pureWhite,
              fontSize: 14,
            ),
            decoration: stitchFilledDecoration(hint: widget.hint),
            onChanged: widget.onChanged,
          ),
        ],
      ),
    );
  }
}
