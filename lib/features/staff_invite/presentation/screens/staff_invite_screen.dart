import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:fithub_portal_admin/config/theme/app_colors.dart';
import 'package:fithub_portal_admin/config/theme/kinetic_tokens.dart';
import 'package:fithub_portal_admin/features/staff_invite/presentation/screens/staff_management_screen.dart';

/// Legacy FEAT-05 entry — prefer [StaffManagementScreen] (FEAT-16 VF3).
///
/// Keeps stitch id citations used by older Verification Audits / tests.
class StaffInviteScreen extends StatelessWidget {
  const StaffInviteScreen({super.key, this.canInvite = true});

  static const String stitchScreenId =
      KineticTokens.stitchStaffInviteScreenId;
  static const String stitchScreenTitle = 'Staff Management';

  final bool canInvite;

  @override
  Widget build(BuildContext context) {
    return StaffManagementScreen(canInvite: canInvite);
  }
}

/// Gate copy for non-Admin callers (UI deny; Backend still enforces 403).
///
/// Prefer [StaffManagementScreen] with `canInvite: false` so §4.1 chrome remains.
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
