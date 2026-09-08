import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/kinetic_tokens.dart';
import '../../../auth/presentation/widgets/stitch_auth_snackbar.dart';
import '../../../memberships/domain/entities/freeze_policy.dart';
import '../../../memberships/domain/entities/membership_plan.dart';
import '../../../memberships/presentation/cubit/memberships_cubit.dart';

/// FEAT-61 US-C — Freeze policy nested under Gym Settings (no dedicated Stitch).
///
/// Visual Spec Card: `Docs/feat61-visual-spec-freeze-policy.md`
class FreezePolicySettingsSection extends StatefulWidget {
  const FreezePolicySettingsSection({
    super.key,
    required this.canWrite,
  });

  final bool canWrite;

  @override
  State<FreezePolicySettingsSection> createState() =>
      _FreezePolicySettingsSectionState();
}

class _FreezePolicySettingsSectionState
    extends State<FreezePolicySettingsSection> {
  final _generalFreezeDays = TextEditingController();
  final _generalMaxDays = TextEditingController();
  String? _selectedPlanId;
  final _planFreezeDays = TextEditingController();
  final _planMaxDays = TextEditingController();
  bool _seededGeneral = false;

  @override
  void initState() {
    super.initState();
    context.read<MembershipsCubit>().load();
  }

  @override
  void dispose() {
    _generalFreezeDays.dispose();
    _generalMaxDays.dispose();
    _planFreezeDays.dispose();
    _planMaxDays.dispose();
    super.dispose();
  }

  void _seedGeneralIfNeeded(List<FreezePolicy> policies) {
    if (_seededGeneral) return;
    for (final p in policies) {
      if (p.isGeneral) {
        _generalFreezeDays.text = '${p.freezeDays}';
        _generalMaxDays.text = '${p.maxFreezeDaysPerTime}';
        _seededGeneral = true;
        return;
      }
    }
  }

  void _loadPlanEditors(List<FreezePolicy> policies, String? planId) {
    _planFreezeDays.clear();
    _planMaxDays.clear();
    if (planId == null) return;
    for (final p in policies) {
      if (p.planId == planId) {
        _planFreezeDays.text = '${p.freezeDays}';
        _planMaxDays.text = '${p.maxFreezeDaysPerTime}';
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<MembershipsCubit, MembershipsState>(
      listenWhen: (prev, next) =>
          next.messageKey != null && next.messageKey != prev.messageKey,
      listener: (context, state) {
        final key = state.messageKey;
        if (key == null || key.isEmpty) return;
        StitchAuthSnackbar.show(context, key.tr());
      },
      builder: (context, state) {
        _seedGeneralIfNeeded(state.freezePolicies);
        final plans = state.plans.where((p) => p.isActive).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'gym_settings.freeze.heading'.tr(),
              style: textTheme.labelLarge?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: KineticTokens.zincGray,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'gym_settings.freeze.subtitle'.tr(),
              style: textTheme.bodySmall?.copyWith(
                color: KineticTokens.zincGray,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'gym_settings.freeze.visual_spec'.tr(),
              style: textTheme.labelSmall?.copyWith(
                fontSize: 10,
                color: KineticTokens.zincGray.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            _PolicyCard(
              title: 'gym_settings.freeze.general_title'.tr(),
              freezeDaysController: _generalFreezeDays,
              maxDaysController: _generalMaxDays,
              enabled: widget.canWrite && !state.busy,
              onSave: widget.canWrite
                  ? () => _save(
                      planId: null,
                      freezeCtrl: _generalFreezeDays,
                      maxCtrl: _generalMaxDays,
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              'gym_settings.freeze.per_plan_title'.tr(),
              style: textTheme.titleSmall?.copyWith(
                color: KineticTokens.pureWhite,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              // ignore: deprecated_member_use
              value: _selectedPlanId,
              dropdownColor: KineticTokens.surfaceContainerLow,
              decoration: InputDecoration(
                labelText: 'gym_settings.freeze.plan_label'.tr(),
              ),
              items: [
                for (final plan in plans)
                  DropdownMenuItem(
                    value: plan.id,
                    child: Text(
                      plan.name,
                      style: const TextStyle(color: KineticTokens.pureWhite),
                    ),
                  ),
              ],
              onChanged: widget.canWrite && !state.busy
                  ? (id) {
                      setState(() {
                        _selectedPlanId = id;
                        _loadPlanEditors(state.freezePolicies, id);
                      });
                    }
                  : null,
            ),
            const SizedBox(height: 12),
            _PolicyCard(
              title: 'gym_settings.freeze.per_plan_card'.tr(),
              freezeDaysController: _planFreezeDays,
              maxDaysController: _planMaxDays,
              enabled:
                  widget.canWrite && !state.busy && _selectedPlanId != null,
              onSave: widget.canWrite && _selectedPlanId != null
                  ? () => _save(
                      planId: _selectedPlanId,
                      freezeCtrl: _planFreezeDays,
                      maxCtrl: _planMaxDays,
                    )
                  : null,
            ),
            if (!widget.canWrite) ...[
              const SizedBox(height: 12),
              Text(
                'gym_settings.freeze.read_only_hint'.tr(),
                style: textTheme.bodySmall?.copyWith(
                  color: KineticTokens.zincGray,
                ),
              ),
            ],
            const SizedBox(height: 12),
            _PoliciesList(policies: state.freezePolicies, plans: state.plans),
          ],
        );
      },
    );
  }

  Future<void> _save({
    required String? planId,
    required TextEditingController freezeCtrl,
    required TextEditingController maxCtrl,
  }) async {
    final freezeDays = int.tryParse(freezeCtrl.text.trim());
    final maxDays = int.tryParse(maxCtrl.text.trim());
    if (freezeDays == null ||
        maxDays == null ||
        maxDays < 1 ||
        freezeDays < 0 ||
        freezeDays > maxDays) {
      StitchAuthSnackbar.show(
        context,
        'gym_settings.freeze.error.invalid'.tr(),
      );
      return;
    }
    final key = await context.read<MembershipsCubit>().upsertFreezePolicy(
      freezeDays: freezeDays,
      maxFreezeDaysPerTime: maxDays,
      planId: planId,
    );
    if (!mounted) return;
    StitchAuthSnackbar.show(context, key.tr());
  }
}

class _PolicyCard extends StatelessWidget {
  const _PolicyCard({
    required this.title,
    required this.freezeDaysController,
    required this.maxDaysController,
    required this.enabled,
    required this.onSave,
  });

  final String title;
  final TextEditingController freezeDaysController;
  final TextEditingController maxDaysController;
  final bool enabled;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: KineticTokens.surfaceContainerLow,
      borderRadius: BorderRadius.circular(KineticTokens.dashboardCardRadius),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: KineticTokens.pureWhite,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: freezeDaysController,
              enabled: enabled,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: KineticTokens.pureWhite),
              decoration: InputDecoration(
                labelText: 'gym_settings.freeze.field_freeze_days'.tr(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: maxDaysController,
              enabled: enabled,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: KineticTokens.pureWhite),
              decoration: InputDecoration(
                labelText: 'gym_settings.freeze.field_max_days'.tr(),
              ),
            ),
            if (onSave != null) ...[
              const SizedBox(height: 16),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: FilledButton(
                  onPressed: enabled ? onSave : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: KineticTokens.electricLime,
                    foregroundColor: KineticTokens.deepCharcoal,
                  ),
                  child: Text('gym_settings.freeze.cta_save'.tr()),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PoliciesList extends StatelessWidget {
  const _PoliciesList({required this.policies, required this.plans});

  final List<FreezePolicy> policies;
  final List<MembershipPlan> plans;

  String _planLabel(String? planId) {
    if (planId == null) return 'gym_settings.freeze.scope_general'.tr();
    for (final p in plans) {
      if (p.id == planId) return p.name;
    }
    return planId;
  }

  @override
  Widget build(BuildContext context) {
    if (policies.isEmpty) {
      return Text(
        'gym_settings.freeze.empty'.tr(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: KineticTokens.zincGray,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'gym_settings.freeze.list_heading'.tr(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontSize: 11,
            letterSpacing: 2,
            color: KineticTokens.zincGray,
          ),
        ),
        const SizedBox(height: 8),
        for (final p in policies)
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: 6),
            child: Text(
              'gym_settings.freeze.list_row'.tr(
                namedArgs: {
                  'scope': _planLabel(p.planId),
                  'days': '${p.freezeDays}',
                  'max': '${p.maxFreezeDaysPerTime}',
                },
              ),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: KineticTokens.pureWhite,
              ),
            ),
          ),
      ],
    );
  }
}
