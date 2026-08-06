import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fithub_portal_admin/config/theme/app_colors.dart';
import 'package:fithub_portal_admin/config/theme/kinetic_tokens.dart';
import 'package:fithub_portal_admin/features/auth/presentation/widgets/stitch_auth_snackbar.dart';
import 'package:fithub_portal_admin/features/staff_invite/domain/entities/staff_role.dart';
import 'package:fithub_portal_admin/features/staff_invite/presentation/bloc/staff_invite_bloc.dart';
import 'package:fithub_portal_admin/features/staff_invite/presentation/fixtures/staff_stitch_fixtures.dart';
import 'package:fithub_portal_admin/features/staff_invite/presentation/widgets/staff_audit_security.dart';
import 'package:fithub_portal_admin/features/staff_invite/presentation/widgets/staff_profile_header.dart';
import 'package:fithub_portal_admin/features/staff_invite/presentation/widgets/staff_shift_log_table.dart';

/// Staff Management / Staff Profile Creator — Stitch `dcc070ef…`.
///
/// Full artboard + §4.1 fixtures. FEAT-05 invite submits name/email/role when
/// [canInvite] is true.
class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key, required this.canInvite});

  /// Stitch Staff Management (DESKTOP).
  static const String stitchScreenId =
      KineticTokens.stitchStaffInviteScreenId;
  static const String stitchScreenIdAr = '6388be3944bb49aa854b41cfaab32135';
  static const String stitchScreenTitle = 'Staff Management';

  final bool canInvite;

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _emergencyController = TextEditingController();
  String _specialization = StaffStitchFixtures.specializationOptions.first;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _emergencyController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!widget.canInvite) return;
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    context.read<StaffInviteBloc>().add(
      StaffInviteSubmitted(
        email: _emailController.text,
        name: _nameController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StaffInviteBloc, StaffInviteState>(
      listenWhen: (previous, current) =>
          current is StaffInviteSuccess ||
          current.messageKey != null ||
          current.messageText != null,
      listener: (context, state) {
        if (state is StaffInviteSuccess) {
          StitchAuthSnackbar.show(context, 'staff_invite.success'.tr());
          _nameController.clear();
          _emailController.clear();
          _emergencyController.clear();
          setState(() {
            _specialization = StaffStitchFixtures.specializationOptions.first;
          });
          context.read<StaffInviteBloc>().add(
            const StaffInviteMessageCleared(),
          );
          return;
        }
        final raw = state.messageKey ?? state.messageText;
        if (raw == null || raw.isEmpty) return;
        final text =
            raw.startsWith('staff_invite.') || raw.startsWith('validation.')
            ? raw.tr()
            : raw;
        StitchAuthSnackbar.show(context, text);
        context.read<StaffInviteBloc>().add(const StaffInviteMessageCleared());
      },
      builder: (context, state) {
        final loading = state is StaffInviteSubmitting;
        final selected = state.selectedRole;

        return Material(
          color: KineticTokens.stitchBackground,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsetsDirectional.all(48),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const StaffProfileHeader(),
                    const SizedBox(height: 48),
                    _CreatorBento(
                      nameController: _nameController,
                      emailController: _emailController,
                      emergencyController: _emergencyController,
                      specialization: _specialization,
                      onSpecialization: (v) =>
                          setState(() => _specialization = v),
                      selected: selected,
                      loading: loading,
                      canInvite: widget.canInvite,
                      onSelectRole: (role) => context
                          .read<StaffInviteBloc>()
                          .add(StaffInviteRoleSelected(role)),
                      onSubmit: _submit,
                    ),
                    const SizedBox(height: 48),
                    const StaffShiftLogHeader(),
                    const SizedBox(height: 24),
                    const StaffShiftLogTable(),
                    const SizedBox(height: 48),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final stack = constraints.maxWidth < 720;
                        if (stack) {
                          return const Column(
                            children: [
                              StaffAuditFeed(),
                              SizedBox(height: 32),
                              StaffSecurityComplianceTile(),
                            ],
                          );
                        }
                        return const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: StaffAuditFeed()),
                            SizedBox(width: 32),
                            Expanded(child: StaffSecurityComplianceTile()),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CreatorBento extends StatelessWidget {
  const _CreatorBento({
    required this.nameController,
    required this.emailController,
    required this.emergencyController,
    required this.specialization,
    required this.onSpecialization,
    required this.selected,
    required this.loading,
    required this.canInvite,
    required this.onSelectRole,
    required this.onSubmit,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController emergencyController;
  final String specialization;
  final ValueChanged<String> onSpecialization;
  final StaffRole selected;
  final bool loading;
  final bool canInvite;
  final ValueChanged<StaffRole> onSelectRole;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final identity = _IdentityCredentialsCard(
          nameController: nameController,
          emailController: emailController,
          emergencyController: emergencyController,
          specialization: specialization,
          onSpecialization: onSpecialization,
          enabled: canInvite && !loading,
        );
        final protocol = _AccessProtocolColumn(
          selected: selected,
          enabled: canInvite && !loading,
          canInvite: canInvite,
          loading: loading,
          onSelect: onSelectRole,
          onSubmit: onSubmit,
        );
        if (!wide) {
          return Column(
            children: [
              identity,
              const SizedBox(height: 32),
              protocol,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 8, child: identity),
            const SizedBox(width: 32),
            Expanded(flex: 4, child: protocol),
          ],
        );
      },
    );
  }
}

class _IdentityCredentialsCard extends StatelessWidget {
  const _IdentityCredentialsCard({
    required this.nameController,
    required this.emailController,
    required this.emergencyController,
    required this.specialization,
    required this.onSpecialization,
    required this.enabled,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController emergencyController;
  final String specialization;
  final ValueChanged<String> onSpecialization;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
          top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Icon(
              Icons.person_add_alt_1_outlined,
              size: 120,
              color: AppColors.outline.withValues(alpha: 0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'staff_invite.identity_section'.tr(),
                style: textTheme.titleMedium?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              LayoutBuilder(
                builder: (context, constraints) {
                  final twoCol = constraints.maxWidth >= 520;
                  final fields = [
                    _LabeledField(
                      label: 'staff_invite.field.name_label'.tr(),
                      child: TextFormField(
                        controller: nameController,
                        enabled: enabled,
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.primary,
                          fontSize: 18,
                        ),
                        decoration: _fieldDecoration(
                          hint: 'staff_invite.field.name_hint'.tr(),
                        ),
                        validator: (value) {
                          if (!enabled) return null;
                          if (value == null || value.trim().isEmpty) {
                            return 'staff_invite.field.name_required'.tr();
                          }
                          return null;
                        },
                      ),
                    ),
                    _LabeledField(
                      label: 'staff_invite.field.email_label'.tr(),
                      child: TextFormField(
                        controller: emailController,
                        enabled: enabled,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.primary,
                          fontSize: 18,
                        ),
                        decoration: _fieldDecoration(
                          hint: 'staff_invite.field.email_hint'.tr(),
                        ),
                        validator: (value) {
                          if (!enabled) return null;
                          if (value == null || value.trim().isEmpty) {
                            return 'staff_invite.field.email_required'.tr();
                          }
                          if (!RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                          ).hasMatch(value.trim())) {
                            return 'validation.email_invalid'.tr();
                          }
                          return null;
                        },
                      ),
                    ),
                    _LabeledField(
                      label: 'staff_invite.field.emergency_label'.tr(),
                      child: TextFormField(
                        controller: emergencyController,
                        enabled: enabled,
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.primary,
                          fontSize: 18,
                        ),
                        decoration: _fieldDecoration(
                          hint: 'staff_invite.field.emergency_hint'.tr(),
                        ),
                      ),
                    ),
                    _LabeledField(
                      label: 'staff_invite.field.specialization_label'.tr(),
                      child: DropdownButtonFormField<String>(
                        key: ValueKey(specialization),
                        initialValue: specialization,
                        isExpanded: true,
                        dropdownColor: AppColors.surfaceContainerHigh,
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.primary,
                          fontSize: 18,
                        ),
                        decoration: _fieldDecoration(hint: ''),
                        items: [
                          for (final opt
                              in StaffStitchFixtures.specializationOptions)
                            DropdownMenuItem(value: opt, child: Text(opt)),
                        ],
                        onChanged: enabled
                            ? (v) {
                                if (v != null) onSpecialization(v);
                              }
                            : null,
                      ),
                    ),
                  ];
                  if (!twoCol) {
                    return Column(
                      children: [
                        for (var i = 0; i < fields.length; i++) ...[
                          if (i > 0) const SizedBox(height: 32),
                          fields[i],
                        ],
                      ],
                    );
                  }
                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: fields[0]),
                          const SizedBox(width: 48),
                          Expanded(child: fields[1]),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: fields[2]),
                          const SizedBox(width: 48),
                          Expanded(child: fields[3]),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint.isEmpty ? null : hint,
      hintStyle: const TextStyle(fontSize: 18, color: Color(0x668E9379)),
      filled: false,
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
      border: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.outlineVariant, width: 2),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.outlineVariant, width: 2),
      ),
      disabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0x4D444933), width: 2),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.primaryFixedDim, width: 2),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        child,
      ],
    );
  }
}

class _AccessProtocolColumn extends StatelessWidget {
  const _AccessProtocolColumn({
    required this.selected,
    required this.enabled,
    required this.canInvite,
    required this.loading,
    required this.onSelect,
    required this.onSubmit,
  });

  final StaffRole selected;
  final bool enabled;
  final bool canInvite;
  final bool loading;
  final ValueChanged<StaffRole> onSelect;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
              top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'staff_invite.protocol_section'.tr(),
                style: textTheme.titleMedium?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              _RoleToggleRow(
                role: StaffRole.admin,
                icon: Icons.admin_panel_settings_outlined,
                accent: AppColors.secondaryContainer,
                selected: selected == StaffRole.admin,
                enabled: enabled,
                onTap: () => onSelect(StaffRole.admin),
              ),
              const SizedBox(height: 16),
              _RoleToggleRow(
                role: StaffRole.coach,
                icon: Icons.fitness_center_outlined,
                accent: AppColors.primaryContainer,
                selected: selected == StaffRole.coach,
                enabled: enabled,
                onTap: () => onSelect(StaffRole.coach),
              ),
              const SizedBox(height: 16),
              _RoleToggleRow(
                role: StaffRole.receptionist,
                icon: Icons.meeting_room_outlined,
                accent: const Color(0xFFB6C9D8),
                selected: selected == StaffRole.receptionist,
                enabled: enabled,
                onTap: () => onSelect(StaffRole.receptionist),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          height: 56,
          child: FilledButton(
            onPressed: (canInvite && !loading) ? onSubmit : null,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              disabledBackgroundColor: AppColors.surfaceBright,
              disabledForegroundColor: AppColors.onSurfaceVariant,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.onPrimary,
                    ),
                  )
                : Text(
                    'staff_invite.cta'.tr(),
                    style: textTheme.titleMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3.2,
                      color: canInvite
                          ? AppColors.onPrimary
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
          ),
        ),
        if (!canInvite) ...[
          const SizedBox(height: 12),
          Text(
            'staff_invite.error.forbidden'.tr(),
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _RoleToggleRow extends StatelessWidget {
  const _RoleToggleRow({
    required this.role,
    required this.icon,
    required this.accent,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final StaffRole role;
  final IconData icon;
  final Color accent;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final titleKey = 'staff_invite.role.${role.name}.title';
    final descKey = 'staff_invite.role.${role.name}.description';

    return Material(
      color: AppColors.surfaceContainerHighest.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(icon, color: accent, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleKey.tr(),
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      descKey.tr(),
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        letterSpacing: 1.2,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              _StitchSwitch(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

/// Visual switch matching Stitch pill (non-Material chrome).
class _StitchSwitch extends StatelessWidget {
  const _StitchSwitch({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 48,
      height: 24,
      padding: const EdgeInsets.all(4),
      alignment: selected
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      decoration: BoxDecoration(
        color: selected
            ? AppColors.primaryContainer
            : AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.onPrimaryContainer
              : AppColors.onSurfaceVariant,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
