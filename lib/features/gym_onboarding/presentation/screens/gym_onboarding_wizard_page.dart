import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/kinetic_tokens.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../staff_invite/domain/entities/staff_role.dart';
import '../../data/gym_onboarding_remote.dart';
import '../gym_onboarding_cubit.dart';

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
  static const double formMaxWidth = 720;

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
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: formMaxWidth),
              child: _WizardBody(onClose: onClose),
            ),
          ),
        ),
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
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Row(
            children: [
              Text(
                'PULSE',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: KineticTokens.electricLime,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  final close = onClose;
                  if (close != null) {
                    close();
                    return;
                  }
                  context.read<AuthBloc>().add(const AuthOnboardingDeferred());
                },
                child: Text('onboarding.finish_later'.tr()),
              ),
            ],
          ),
        ),
        _Stepper(step: state.step),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: switch (state.step) {
              0 => const _BrandStep(),
              1 => const _BranchStep(),
              2 => const _StaffStep(),
              3 => const _PlanStep(),
              _ => const _ReviewStep(),
            },
          ),
        ),
      ],
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.step});
  final int step;

  @override
  Widget build(BuildContext context) {
    const labels = ['Brand', 'Branches', 'Staff', 'Plans', 'Publish'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: i <= step
                        ? KineticTokens.electricLime
                        : KineticTokens.surfaceContainerHigh,
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        color: i <= step
                            ? KineticTokens.deepCharcoal
                            : KineticTokens.zincGray,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    labels[i],
                    style: TextStyle(
                      color: i == step
                          ? KineticTokens.electricLime
                          : KineticTokens.zincGray,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

InputDecoration _dec(String label) => InputDecoration(
  labelText: label,
  labelStyle: const TextStyle(color: KineticTokens.zincGray),
  enabledBorder: const UnderlineInputBorder(
    borderSide: BorderSide(color: KineticTokens.surfaceContainerHigh),
  ),
  focusedBorder: const UnderlineInputBorder(
    borderSide: BorderSide(color: KineticTokens.electricLime),
  ),
);

class _BrandStep extends StatelessWidget {
  const _BrandStep();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GymOnboardingCubit>();
    final s = context.watch<GymOnboardingCubit>().state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'onboarding.step1.title'.tr(),
          style: const TextStyle(
            color: KineticTokens.pureWhite,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 16),
        _BoundField(
          value: s.brandName,
          label: 'onboarding.step1.brand'.tr(),
          onChanged: (v) => cubit.patch(s.copyWith(brandName: v)),
        ),
        _BoundField(
          value: s.tradingName,
          label: 'onboarding.step1.trading'.tr(),
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
        const SizedBox(height: 24),
        _LimeButton(
          label: 'onboarding.next_branches'.tr(),
          busy: s.saving,
          onTap: () => cubit.saveBrand(),
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
        Text(
          'onboarding.step2.title'.tr(),
          style: const TextStyle(
            color: KineticTokens.pureWhite,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
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
          value: '${s.capacity}',
          label: 'onboarding.step2.capacity'.tr(),
          keyboardType: TextInputType.number,
          onChanged: (v) =>
              cubit.patch(s.copyWith(capacity: int.tryParse(v) ?? s.capacity)),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tag in GymOnboardingRemote.amenityTags)
              FilterChip(
                label: Text(tag),
                selected: s.amenityTags.contains(tag),
                selectedColor: KineticTokens.electricLime,
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
        TextButton(
          onPressed: () => cubit.setStep(0),
          child: Text('onboarding.back'.tr()),
        ),
        const SizedBox(height: 12),
        _LimeButton(
          label: 'onboarding.next_staff'.tr(),
          busy: s.saving,
          onTap: () => cubit.saveBranch(),
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
        Text(
          'onboarding.step3.title'.tr(),
          style: const TextStyle(
            color: KineticTokens.pureWhite,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          'onboarding.step3.honesty'.tr(),
          style: const TextStyle(color: KineticTokens.zincGray),
        ),
        TextField(
          controller: email,
          style: const TextStyle(color: KineticTokens.pureWhite),
          decoration: _dec('onboarding.step3.email'.tr()),
        ),
        TextField(
          controller: name,
          style: const TextStyle(color: KineticTokens.pureWhite),
          decoration: _dec('onboarding.step3.name'.tr()),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: s.saving
              ? null
              : () => cubit.inviteStaff(
                  email: email.text,
                  name: name.text,
                  role: StaffRole.receptionist,
                ),
          child: Text('onboarding.step3.invite_desk'.tr()),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => cubit.setStep(1),
          child: Text('onboarding.back'.tr()),
        ),
        const SizedBox(height: 12),
        _LimeButton(
          label: 'onboarding.next_plans'.tr(),
          busy: s.saving,
          onTap: cubit.skipStaff,
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
        Text(
          'onboarding.step4.title'.tr(),
          style: const TextStyle(
            color: KineticTokens.pureWhite,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        _BoundField(
          value: s.planName,
          label: 'onboarding.step4.name'.tr(),
          onChanged: (v) => cubit.patch(s.copyWith(planName: v)),
        ),
        _BoundField(
          value: '${s.planDays}',
          label: 'onboarding.step4.days'.tr(),
          keyboardType: TextInputType.number,
          onChanged: (v) =>
              cubit.patch(s.copyWith(planDays: int.tryParse(v) ?? s.planDays)),
        ),
        _BoundField(
          value: '${s.planPriceEgp}',
          label: 'onboarding.step4.price'.tr(),
          keyboardType: TextInputType.number,
          onChanged: (v) => cubit.patch(
            s.copyWith(planPriceEgp: int.tryParse(v) ?? s.planPriceEgp),
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
        TextButton(
          onPressed: () => cubit.setStep(2),
          child: Text('onboarding.back'.tr()),
        ),
        const SizedBox(height: 12),
        _LimeButton(
          label: 'onboarding.next_review'.tr(),
          busy: s.saving,
          onTap: () => cubit.savePlan(),
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
        Text(
          'onboarding.step5.title'.tr(),
          style: const TextStyle(
            color: KineticTokens.pureWhite,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 16),
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
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => cubit.setStep(3),
          child: Text('onboarding.back'.tr()),
        ),
        const SizedBox(height: 12),
        _LimeButton(
          label: 'onboarding.publish.cta'.tr(),
          busy: s.saving,
          enabled: s.canPublish,
          onTap: () async {
            final ok = await cubit.publish();
            if (ok && context.mounted) {
              context.read<AuthBloc>().add(const AuthProfileRefreshRequested());
            }
          },
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
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: KineticTokens.electricLime,
        foregroundColor: KineticTokens.deepCharcoal,
        minimumSize: const Size.fromHeight(52),
      ),
      onPressed: (!enabled || busy) ? null : onTap,
      child: busy
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}

class _BoundField extends StatefulWidget {
  const _BoundField({
    required this.value,
    required this.label,
    required this.onChanged,
    this.keyboardType,
  });

  final String value;
  final String label;
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
    return TextField(
      controller: _controller,
      keyboardType: widget.keyboardType,
      style: const TextStyle(color: KineticTokens.pureWhite),
      decoration: _dec(widget.label),
      onChanged: widget.onChanged,
    );
  }
}
