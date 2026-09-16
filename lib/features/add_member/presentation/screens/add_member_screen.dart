import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/kinetic_tokens.dart';
import '../../../auth/presentation/widgets/stitch_auth_snackbar.dart';
import '../../../memberships/domain/entities/membership_plan.dart';
import '../../domain/entities/athlete_enroll_match.dart';
import '../bloc/add_member_bloc.dart';

/// Stitch G4 Add New Member — modal dialog over Members hub.
///
/// EN `cd59a129a24449478a5249ccb41635fb` · AR `89fe5d7afb8d4d4384d7e6498bcdd065`
/// Visual Spec: `Docs/feat95-visual-spec-g4.md`
///
/// FEAT-59: form shell centered (max-width 720). FEAT-95: overlay + stepper;
/// RTL search icon at LTR start; searching suffix does not cover the query.
class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key, this.onEnrolled});

  /// Called after successful enroll/invite with i18n message key.
  final ValueChanged<String>? onEnrolled;

  static const String stitchScreenIdEn = 'cd59a129a24449478a5249ccb41635fb';
  static const String stitchScreenIdAr = '89fe5d7afb8d4d4384d7e6498bcdd065';
  static const String stitchScreenTitle = 'Add New Member';

  /// FEAT-59 — wide-layout form max width (centered).
  static const double formMaxWidth = 720;

  /// Stitch `rounded-2xl`.
  static const double dialogRadius = 16;

  static const Duration searchDebounce = Duration(milliseconds: 300);

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final _searchController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    context.read<AddMemberBloc>().add(const AddMemberStarted());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(AddMemberScreen.searchDebounce, () {
      if (!mounted) return;
      context.read<AddMemberBloc>().add(AddMemberSearchRequested(value));
    });
  }

  void _close() {
    final nav = Navigator.of(context);
    if (nav.canPop()) nav.pop();
  }

  void _submit(AddMemberState state) {
    if (state.busy) return;
    final match = state.match;
    if (match != null) {
      context.read<AddMemberBloc>().add(const AddMemberEnrollRequested());
      return;
    }
    context.read<AddMemberBloc>().add(
      AddMemberInviteRequested(
        identifier: _searchController.text,
        displayName: _nameController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddMemberBloc, AddMemberState>(
      listenWhen: (prev, next) =>
          (next.messageKey != null && next.messageKey != prev.messageKey) ||
          (next.status == AddMemberStatus.success &&
              prev.status != AddMemberStatus.success),
      listener: (context, state) {
        if (state.status == AddMemberStatus.success) {
          final key = state.messageKey ?? 'add_member.success.enrolled';
          widget.onEnrolled?.call(key);
          _close();
          return;
        }
        if (state.messageKey == 'add_member.success.invite_sent') {
          widget.onEnrolled?.call('add_member.success.invite_sent');
          _close();
          return;
        }
        final key = state.messageKey;
        if (key != null && key.isNotEmpty) {
          final text = key.contains('.') ? key.tr() : key;
          StitchAuthSnackbar.show(context, text);
          context.read<AddMemberBloc>().add(const AddMemberMessageCleared());
        }
      },
      builder: (context, state) {
        return Material(
          type: MaterialType.transparency,
          child: Stack(
            fit: StackFit.expand,
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: const ColoredBox(color: Color(0xE6131313)),
              ),
              Align(
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: AddMemberScreen.formMaxWidth,
                    maxHeight: MediaQuery.sizeOf(context).height * 0.92,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: SizedBox.expand(
                      child: _AddMemberDialogCard(
                        state: state,
                        searchController: _searchController,
                        nameController: _nameController,
                        phoneController: _phoneController,
                        onSearchChanged: _onSearchChanged,
                        onClose: _close,
                        onSubmit: () => _submit(state),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AddMemberDialogCard extends StatelessWidget {
  const _AddMemberDialogCard({
    required this.state,
    required this.searchController,
    required this.nameController,
    required this.phoneController,
    required this.onSearchChanged,
    required this.onClose,
    required this.onSubmit,
  });

  final AddMemberState state;
  final TextEditingController searchController;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClose;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: KineticTokens.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AddMemberScreen.dialogRadius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: KineticTokens.primaryContainer.withValues(alpha: 0.08),
            blurRadius: 32,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AddMemberScreen.dialogRadius),
        child: Column(
          children: [
            const _DialogAccentBar(),
            _DialogHeader(state: state, onClose: onClose),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(32, 8, 32, 24),
                child: state.wizardStep == 2
                    ? _AssignPlanStep(state: state)
                    : _FindInviteStep(
                        state: state,
                        searchController: searchController,
                        nameController: nameController,
                        phoneController: phoneController,
                        onSearchChanged: onSearchChanged,
                      ),
              ),
            ),
            _DialogFooter(state: state, onClose: onClose, onSubmit: onSubmit),
          ],
        ),
      ),
    );
  }
}

class _DialogAccentBar extends StatelessWidget {
  const _DialogAccentBar();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 4,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              KineticTokens.primaryContainer,
              KineticTokens.secondaryContainer,
              KineticTokens.primaryContainer,
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.state, required this.onClose});

  final AddMemberState state;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 32, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'add_member.title'.tr(),
                      style: textTheme.headlineMedium?.copyWith(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: KineticTokens.onSurface,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'add_member.subtitle'.tr(),
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        letterSpacing: 0.6,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onClose,
                tooltip: 'add_member.cta.cancel_request'.tr(),
                icon: const Icon(
                  Icons.close,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _DialogStepper(step: state.wizardStep),
        ],
      ),
    );
  }
}

class _DialogStepper extends StatelessWidget {
  const _DialogStepper({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AddMemberBloc>();
    return Row(
      children: [
        _StepChip(
          indexLabel: '01',
          title: 'add_member.step.find'.tr(),
          active: step == 1,
          onTap: () => bloc.add(const AddMemberWizardStepChanged(1)),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: SizedBox(
                height: 2,
                child: ColoredBox(
                  color: AppColors.surfaceContainerHigh,
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: FractionallySizedBox(
                      widthFactor: step == 1 ? 0.5 : 1,
                      child: ColoredBox(
                        color: KineticTokens.primaryContainer.withValues(
                          alpha: 0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        _StepChip(
          indexLabel: '02',
          title: 'add_member.step.plan'.tr(),
          active: step == 2,
          dimmed: step != 2,
          onTap: () => bloc.add(const AddMemberWizardStepChanged(2)),
        ),
      ],
    );
  }
}

class _StepChip extends StatelessWidget {
  const _StepChip({
    required this.indexLabel,
    required this.title,
    required this.active,
    required this.onTap,
    this.dimmed = false,
  });

  final String indexLabel;
  final String title;
  final bool active;
  final bool dimmed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final badgeColor = active
        ? KineticTokens.primaryContainer
        : AppColors.surfaceContainerHighest;
    final badgeText = active
        ? KineticTokens.onPrimaryContainer
        : KineticTokens.onSurface;
    final labelColor = active
        ? KineticTokens.primaryContainer
        : KineticTokens.onSurface;
    return Opacity(
      opacity: dimmed ? 0.4 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                indexLabel,
                style: TextStyle(
                  color: badgeText,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: labelColor,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FindInviteStep extends StatelessWidget {
  const _FindInviteStep({
    required this.state,
    required this.searchController,
    required this.nameController,
    required this.phoneController,
    required this.onSearchChanged,
  });

  final AddMemberState state;
  final TextEditingController searchController;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionLabel(text: 'add_member.search_label'.tr()),
        const SizedBox(height: 12),
        _DeskSearchField(
          controller: searchController,
          searching: state.status == AddMemberStatus.finding,
          enabled: !state.busy || state.status == AddMemberStatus.finding,
          onChanged: onSearchChanged,
        ),
        if (state.matches.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...state.matches.map(
            (match) =>
                _MatchCard(match: match, selected: state.match?.id == match.id),
          ),
        ] else if (state.query.isNotEmpty &&
            state.status != AddMemberStatus.finding) ...[
          const SizedBox(height: 8),
          Text(
            'add_member.no_matches'.tr(),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
        const SizedBox(height: 24),
        const _CreateDivider(),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 520;
            final nameField = _UnderlineField(
              controller: nameController,
              label: 'add_member.field.legal_name'.tr(),
              hint: 'add_member.field.legal_name_hint'.tr(),
              enabled: !state.busy,
              textCapitalization: TextCapitalization.words,
            );
            final phoneField = _PhoneField(
              controller: phoneController,
              enabled: !state.busy,
            );
            if (!wide) {
              return Column(
                children: [nameField, const SizedBox(height: 24), phoneField],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: nameField),
                const SizedBox(width: 32),
                Expanded(child: phoneField),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        const _VerificationCallout(),
        const SizedBox(height: 12),
        Text(
          'add_member.visual_spec'.tr(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 11,
            color: KineticTokens.zincGray,
          ),
        ),
      ],
    );
  }
}

class _AssignPlanStep extends StatelessWidget {
  const _AssignPlanStep({required this.state});

  final AddMemberState state;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionLabel(text: 'add_member.field.plan_optional'.tr()),
        const SizedBox(height: 12),
        DropdownButtonFormField<String?>(
          initialValue: state.selectedPlanId,
          dropdownColor: KineticTokens.gunmetalCard,
          style: const TextStyle(color: KineticTokens.pureWhite),
          decoration: InputDecoration(
            filled: true,
            fillColor: KineticTokens.surfaceContainerLowest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                KineticTokens.dashboardCardRadius,
              ),
            ),
          ),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text('add_member.plan.none'.tr()),
            ),
            ...state.plans.map(
              (MembershipPlan plan) => DropdownMenuItem<String?>(
                value: plan.id,
                child: Text(plan.name),
              ),
            ),
          ],
          onChanged: state.busy
              ? null
              : (value) => context.read<AddMemberBloc>().add(
                  AddMemberPlanSelected(value),
                ),
        ),
        if (state.match != null) ...[
          const SizedBox(height: 24),
          Text(
            state.match!.fullName,
            style: textTheme.titleMedium?.copyWith(
              color: KineticTokens.pureWhite,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (state.match!.publicCode != null)
            Text(
              state.match!.publicCode!,
              style: textTheme.bodySmall?.copyWith(
                color: KineticTokens.zincGray,
              ),
            ),
        ],
      ],
    );
  }
}

class _DeskSearchField extends StatelessWidget {
  const _DeskSearchField({
    required this.controller,
    required this.searching,
    required this.enabled,
    required this.onChanged,
  });

  final TextEditingController controller;
  final bool searching;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: TextField(
        key: const Key('add_member_search_field'),
        controller: controller,
        enabled: enabled,
        onChanged: onChanged,
        keyboardType: TextInputType.text,
        style: const TextStyle(
          color: KineticTokens.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: 'add_member.search_hint'.tr(),
          hintStyle: TextStyle(
            color: KineticTokens.onSurface.withValues(alpha: 0.3),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
          filled: true,
          fillColor: KineticTokens.surfaceContainerLowest,
          contentPadding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
          prefixIcon: const Icon(
            Icons.search,
            color: KineticTokens.primaryContainer,
          ),
          suffix: searching
              ? Text(
                  'add_member.searching'.tr(),
                  style: const TextStyle(
                    color: KineticTokens.primaryContainer,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                )
              : null,
          border: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.surfaceContainerHighest,
              width: 2,
            ),
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.surfaceContainerHighest,
              width: 2,
            ),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: KineticTokens.primaryContainer,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.match, required this.selected});

  final AthleteEnrollMatch match;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected
            ? KineticTokens.primaryContainer.withValues(alpha: 0.08)
            : KineticTokens.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () =>
              context.read<AddMemberBloc>().add(AddMemberMatchSelected(match)),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.surfaceContainerHigh,
                  child: Text(
                    match.fullName.trim().isEmpty
                        ? '?'
                        : match.fullName.trim().substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: KineticTokens.primaryContainer,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        match.fullName,
                        style: const TextStyle(
                          color: KineticTokens.pureWhite,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        [
                          match.publicCode,
                          match.email,
                          match.phoneE164,
                        ].whereType<String>().join(' · '),
                        style: const TextStyle(
                          color: KineticTokens.zincGray,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  const Icon(
                    Icons.check_circle,
                    color: KineticTokens.primaryContainer,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateDivider extends StatelessWidget {
  const _CreateDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.05))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'add_member.create_divider'.tr(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.4,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.05))),
      ],
    );
  }
}

class _UnderlineField extends StatelessWidget {
  const _UnderlineField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.enabled,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool enabled;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(text: label),
        TextField(
          controller: controller,
          enabled: enabled,
          textCapitalization: textCapitalization,
          style: const TextStyle(
            color: KineticTokens.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0x1AFFFFFF)),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0x1AFFFFFF)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: KineticTokens.primaryContainer),
            ),
          ),
        ),
      ],
    );
  }
}

class _PhoneField extends StatelessWidget {
  const _PhoneField({required this.controller, required this.enabled});

  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(text: 'add_member.field.phone'.tr()),
        Directionality(
          textDirection: TextDirection.ltr,
          child: TextField(
            controller: controller,
            enabled: enabled,
            keyboardType: TextInputType.phone,
            style: const TextStyle(
              color: KineticTokens.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  widthFactor: 1,
                  child: Text(
                    'add_member.field.phone_prefix'.tr(),
                    style: const TextStyle(
                      color: KineticTokens.primaryContainer,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
              hintText: 'add_member.field.phone_hint'.tr(),
              hintStyle: TextStyle(
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
              ),
              border: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0x1AFFFFFF)),
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0x1AFFFFFF)),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: KineticTokens.primaryContainer),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _VerificationCallout extends StatelessWidget {
  const _VerificationCallout();

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: KineticTokens.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: KineticTokens.primaryContainer.withValues(alpha: 0.1),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              bottom: 0,
              right: isRtl ? 0 : null,
              left: isRtl ? null : 0,
              child: Container(
                width: 4,
                color: KineticTokens.primaryContainer.withValues(alpha: 0.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: KineticTokens.primaryContainer.withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.info,
                      color: KineticTokens.primaryContainer,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'add_member.verify_title'.tr(),
                          style: const TextStyle(
                            color: KineticTokens.primaryContainer,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'add_member.verify_body'.tr(),
                          style: const TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 13,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.6,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }
}

class _DialogFooter extends StatelessWidget {
  const _DialogFooter({
    required this.state,
    required this.onClose,
    required this.onSubmit,
  });

  final AddMemberState state;
  final VoidCallback onClose;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AddMemberBloc>();
    final submitting =
        state.status == AddMemberStatus.enrolling ||
        state.status == AddMemberStatus.inviting;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      decoration: BoxDecoration(
        color: KineticTokens.surfaceContainerLowest.withValues(alpha: 0.5),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 12,
        spacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          TextButton(
            onPressed: onClose,
            child: Text(
              'add_member.cta.cancel_request'.tr(),
              style: const TextStyle(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
          ),
          Wrap(
            spacing: 12,
            children: [
              FilledButton(
                onPressed: state.busy
                    ? null
                    : () => bloc.add(
                        AddMemberWizardStepChanged(
                          state.wizardStep == 1 ? 2 : 1,
                        ),
                      ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.surfaceContainerHigh,
                  foregroundColor: KineticTokens.onSurface,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  state.wizardStep == 1
                      ? 'add_member.cta.next_step'.tr()
                      : 'add_member.cta.back_step'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              FilledButton(
                key: const Key('add_member_enroll_assign'),
                onPressed: state.busy ? null : onSubmit,
                style: FilledButton.styleFrom(
                  backgroundColor: KineticTokens.primaryContainer,
                  foregroundColor: KineticTokens.onPrimaryContainer,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (submitting)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Text(
                        'add_member.cta.enroll_assign'.tr(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    if (!submitting) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 18),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
