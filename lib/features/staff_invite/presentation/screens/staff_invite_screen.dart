import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fithub_portal_admin/config/theme/app_colors.dart';
import 'package:fithub_portal_admin/features/auth/presentation/widgets/stitch_auth_snackbar.dart';
import 'package:fithub_portal_admin/features/staff_invite/domain/entities/staff_role.dart';
import 'package:fithub_portal_admin/features/staff_invite/presentation/bloc/staff_invite_bloc.dart';

/// Stitch **Staff Management** invite form
/// (`screens/dcc070ef2b1e45058b3e042ad70140e3` — Staff Profile Creator).
class StaffInviteScreen extends StatefulWidget {
  const StaffInviteScreen({super.key});

  static const String stitchScreenId = 'dcc070ef2b1e45058b3e042ad70140e3';
  static const String stitchScreenTitle = 'Staff Management';

  @override
  State<StaffInviteScreen> createState() => _StaffInviteScreenState();
}

class _StaffInviteScreenState extends State<StaffInviteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
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
    final textTheme = Theme.of(context).textTheme;

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

        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'staff_invite.title'.tr(),
                  textAlign: TextAlign.start,
                  style: textTheme.headlineMedium?.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'staff_invite.subtitle'.tr(),
                  textAlign: TextAlign.start,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 720;
                    final identity = _IdentityCredentialsCard(
                      nameController: _nameController,
                      emailController: _emailController,
                    );
                    final protocol = _AccessProtocolCard(
                      selected: selected,
                      enabled: !loading,
                      onSelect: (role) => context.read<StaffInviteBloc>().add(
                        StaffInviteRoleSelected(role),
                      ),
                    );
                    if (!wide) {
                      return Column(
                        children: [
                          identity,
                          const SizedBox(height: 16),
                          protocol,
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: identity),
                        const SizedBox(width: 16),
                        Expanded(flex: 2, child: protocol),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: loading ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      disabledBackgroundColor: AppColors.surfaceBright,
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
                              letterSpacing: 2.4,
                              color: AppColors.onPrimary,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _IdentityCredentialsCard extends StatelessWidget {
  const _IdentityCredentialsCard({
    required this.nameController,
    required this.emailController,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'staff_invite.identity_section'.tr(),
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Icon(
                Icons.person_add_alt_1_outlined,
                color: AppColors.outline.withValues(alpha: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'staff_invite.field.name_label'.tr(),
            style: textTheme.labelLarge?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          TextFormField(
            controller: nameController,
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.primary,
              fontSize: 16,
            ),
            decoration: _fieldDecoration(
              hint: 'staff_invite.field.name_hint'.tr(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'staff_invite.field.name_required'.tr();
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          Text(
            'staff_invite.field.email_label'.tr(),
            style: textTheme.labelLarge?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.primary,
              fontSize: 16,
            ),
            decoration: _fieldDecoration(
              hint: 'staff_invite.field.email_hint'.tr(),
            ),
            validator: (value) {
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
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 16, color: Color(0x668E9379)),
      filled: false,
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
      border: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0x4D444933), width: 2),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0x4D444933), width: 2),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.primaryFixedDim, width: 2),
      ),
    );
  }
}

class _AccessProtocolCard extends StatelessWidget {
  const _AccessProtocolCard({
    required this.selected,
    required this.enabled,
    required this.onSelect,
  });

  final StaffRole selected;
  final bool enabled;
  final ValueChanged<StaffRole> onSelect;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'staff_invite.protocol_section'.tr(),
            style: textTheme.titleMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          _RoleToggleRow(
            role: StaffRole.admin,
            icon: Icons.admin_panel_settings_outlined,
            accent: AppColors.secondaryContainer,
            selected: selected == StaffRole.admin,
            enabled: enabled,
            onTap: () => onSelect(StaffRole.admin),
          ),
          const SizedBox(height: 12),
          _RoleToggleRow(
            role: StaffRole.coach,
            icon: Icons.fitness_center_outlined,
            accent: AppColors.electricLime,
            selected: selected == StaffRole.coach,
            enabled: enabled,
            onTap: () => onSelect(StaffRole.coach),
          ),
          const SizedBox(height: 12),
          _RoleToggleRow(
            role: StaffRole.receptionist,
            icon: Icons.storefront_outlined,
            accent: AppColors.outline,
            selected: selected == StaffRole.receptionist,
            enabled: enabled,
            onTap: () => onSelect(StaffRole.receptionist),
          ),
        ],
      ),
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
      color: AppColors.surfaceContainer,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: accent, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleKey.tr(),
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
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
              Switch.adaptive(
                value: selected,
                onChanged: enabled ? (_) => onTap() : null,
                activeThumbColor: AppColors.electricLime,
                activeTrackColor: AppColors.electricLime.withValues(
                  alpha: 0.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Gate for non-Admin callers (UI deny; Backend still enforces 403).
class StaffInviteDeniedView extends StatelessWidget {
  const StaffInviteDeniedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(24),
        child: Text(
          'staff_invite.error.forbidden'.tr(),
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.onSurfaceVariant),
        ),
      ),
    );
  }
}
