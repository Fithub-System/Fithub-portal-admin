import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/kinetic_tokens.dart';
import '../../../auth/presentation/widgets/stitch_auth_snackbar.dart';
import '../../domain/entities/membership_plan.dart';
import '../cubit/memberships_cubit.dart';

/// Membership plans + assign (FEAT-07). Kinetic + companion Admin Overview
/// `216e0407184f4c39bd501ed436c1e88b` (Stitch MCP unavailable this session).
class MembershipsScreen extends StatefulWidget {
  const MembershipsScreen({super.key, required this.canWrite});

  static const String stitchCompanionScreenId =
      '216e0407184f4c39bd501ed436c1e88b';
  static const String stitchCompanionTitle = 'Admin Overview';

  /// Admin-only create / deactivate / assign (AC-A3 / AC-B4).
  final bool canWrite;

  @override
  State<MembershipsScreen> createState() => _MembershipsScreenState();
}

class _MembershipsScreenState extends State<MembershipsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MembershipsCubit>().load();
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
        if (state.status == MembershipsStatus.loading ||
            state.status == MembershipsStatus.initial) {
          return const Center(
            child: CircularProgressIndicator(
              color: KineticTokens.electricLime,
            ),
          );
        }

        if (state.status == MembershipsStatus.failure &&
            state.plans.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsetsDirectional.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    (state.messageKey ?? 'memberships.error.unknown').tr(),
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: KineticTokens.zincGray,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.read<MembershipsCubit>().load(),
                    child: Text('memberships.retry'.tr()),
                  ),
                ],
              ),
            ),
          );
        }

        return Stack(
          children: [
            ListView(
              padding: const EdgeInsetsDirectional.all(24),
              children: [
                Text(
                  'memberships.title'.tr(),
                  textAlign: TextAlign.start,
                  style: textTheme.headlineMedium?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'memberships.subtitle'.tr(),
                  textAlign: TextAlign.start,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                if (widget.canWrite) ...[
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.icon(
                        onPressed: state.busy
                            ? null
                            : () => _openCreatePlanSheet(context),
                        icon: const Icon(Icons.add),
                        label: Text('memberships.cta.create_plan'.tr()),
                        style: FilledButton.styleFrom(
                          backgroundColor: KineticTokens.electricLime,
                          foregroundColor: KineticTokens.deepCharcoal,
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: state.busy || state.plans.isEmpty
                            ? null
                            : () => _openAssignSheet(context, state),
                        icon: const Icon(Icons.person_add_alt_1),
                        label: Text('memberships.cta.assign'.tr()),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: KineticTokens.electricLime,
                          side: const BorderSide(
                            color: KineticTokens.electricLime,
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  Text(
                    'memberships.read_only_hint'.tr(),
                    style: textTheme.bodySmall?.copyWith(
                      color: KineticTokens.zincGray,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  'memberships.plans_heading'.tr(),
                  style: textTheme.labelLarge?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: KineticTokens.zincGray,
                  ),
                ),
                const SizedBox(height: 12),
                if (state.plans.isEmpty)
                  Text(
                    'memberships.empty_plans'.tr(),
                    style: textTheme.bodyMedium?.copyWith(
                      color: KineticTokens.zincGray,
                    ),
                  )
                else
                  ...state.plans.map(
                    (plan) => _PlanTile(
                      plan: plan,
                      canWrite: widget.canWrite,
                      busy: state.busy,
                      onDeactivate: () => context
                          .read<MembershipsCubit>()
                          .deactivatePlan(plan.id),
                    ),
                  ),
              ],
            ),
            if (state.busy)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0x66000000),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: KineticTokens.electricLime,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _openCreatePlanSheet(BuildContext context) async {
    final cubit = context.read<MembershipsCubit>();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final durationController = TextEditingController(text: '30');
    final priceController = TextEditingController(text: '0');
    final formKey = GlobalKey<FormState>();

    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: KineticTokens.gunmetalCard,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsetsDirectional.only(
            start: 24,
            end: 24,
            top: 24,
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'memberships.create_title'.tr(),
                  style: const TextStyle(
                    color: KineticTokens.pureWhite,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'memberships.field.name'.tr(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty)
                      ? 'validation.field_empty'.tr()
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'memberships.field.description'.tr(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: durationController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'memberships.field.duration_days'.tr(),
                  ),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 1) {
                      return 'memberships.validation.duration'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'memberships.field.price_cents'.tr(),
                  ),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 0) {
                      return 'memberships.validation.price'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() != true) return;
                    Navigator.of(sheetContext).pop(true);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: KineticTokens.electricLime,
                    foregroundColor: KineticTokens.deepCharcoal,
                  ),
                  child: Text('memberships.cta.save_plan'.tr()),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (submitted == true && context.mounted) {
      await cubit.createPlan(
        name: nameController.text,
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text,
        durationDays: int.parse(durationController.text),
        priceCents: int.parse(priceController.text),
      );
    }

    nameController.dispose();
    descriptionController.dispose();
    durationController.dispose();
    priceController.dispose();
  }

  Future<void> _openAssignSheet(
    BuildContext context,
    MembershipsState state,
  ) async {
    final cubit = context.read<MembershipsCubit>();
    final activePlans =
        state.plans.where((p) => p.isActive).toList(growable: false);
    if (activePlans.isEmpty || state.athletes.isEmpty) {
      StitchAuthSnackbar.show(
        context,
        'memberships.error.assign_prereq'.tr(),
      );
      return;
    }

    var selectedPlanId = activePlans.first.id;
    var selectedAthleteId = state.athletes.first.id;

    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: KineticTokens.gunmetalCard,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsetsDirectional.only(
                start: 24,
                end: 24,
                top: 24,
                bottom: MediaQuery.viewInsetsOf(sheetContext).bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'memberships.assign_title'.tr(),
                    style: const TextStyle(
                      color: KineticTokens.pureWhite,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedPlanId,
                    decoration: InputDecoration(
                      labelText: 'memberships.field.plan'.tr(),
                    ),
                    items: activePlans
                        .map(
                          (p) => DropdownMenuItem(
                            value: p.id,
                            child: Text(p.name),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (v) {
                      if (v == null) return;
                      setModalState(() => selectedPlanId = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedAthleteId,
                    decoration: InputDecoration(
                      labelText: 'memberships.field.athlete'.tr(),
                    ),
                    items: state.athletes
                        .map(
                          (a) => DropdownMenuItem(
                            value: a.id,
                            child: Text(a.fullName),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (v) {
                      if (v == null) return;
                      setModalState(() => selectedAthleteId = v);
                    },
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => Navigator.of(sheetContext).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: KineticTokens.electricLime,
                      foregroundColor: KineticTokens.deepCharcoal,
                    ),
                    child: Text('memberships.cta.confirm_assign'.tr()),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (submitted == true && context.mounted) {
      await cubit.assign(
        planId: selectedPlanId,
        athleteId: selectedAthleteId,
      );
    }
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({
    required this.plan,
    required this.canWrite,
    required this.busy,
    required this.onDeactivate,
  });

  final MembershipPlan plan;
  final bool canWrite;
  final bool busy;
  final VoidCallback onDeactivate;

  @override
  Widget build(BuildContext context) {
    final price = (plan.priceCents / 100).toStringAsFixed(2);
    return Container(
      margin: const EdgeInsetsDirectional.only(bottom: 12),
      padding: const EdgeInsetsDirectional.all(16),
      decoration: BoxDecoration(
        color: KineticTokens.gunmetalCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KineticTokens.zincGray.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.name,
                  style: const TextStyle(
                    color: KineticTokens.pureWhite,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'memberships.plan_meta'.tr(
                    namedArgs: {
                      'days': '${plan.durationDays}',
                      'price': price,
                      'currency': plan.currency,
                    },
                  ),
                  style: const TextStyle(
                    color: KineticTokens.zincGray,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  plan.isActive
                      ? 'memberships.status.active'.tr()
                      : 'memberships.status.inactive'.tr(),
                  style: TextStyle(
                    color: plan.isActive
                        ? KineticTokens.electricLime
                        : KineticTokens.zincGray,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (canWrite && plan.isActive)
            TextButton(
              onPressed: busy ? null : onDeactivate,
              child: Text('memberships.cta.deactivate'.tr()),
            ),
        ],
      ),
    );
  }
}
