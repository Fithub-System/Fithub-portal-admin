import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fithub_portal_admin/config/theme/app_colors.dart';
import 'package:fithub_portal_admin/features/auth/presentation/bloc/auth_bloc.dart';

/// Post-login Portal home shell (Phase 1.1 — no dashboard feature work).
class PortalHomeShell extends StatelessWidget {
  const PortalHomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.select(
      (AuthBloc b) => b.state is AuthAuthenticated
          ? (b.state as AuthAuthenticated).profile
          : null,
    );
    final dash = 'home.shell.em_dash'.tr();
    final name = profile?.name ?? 'home.shell.admin_fallback'.tr();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'home.shell.welcome'.tr(namedArgs: {'name': name}),
                      textAlign: TextAlign.start,
                      style: textTheme.titleLarge?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.pureWhite,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'home.shell.sign_out'.tr(),
                    onPressed: () => context.read<AuthBloc>().add(
                          const AuthSignOutRequested(),
                        ),
                    icon: const Icon(Icons.logout, color: AppColors.zinc500),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'home.shell.command_center'.tr(),
                textAlign: TextAlign.start,
                style: textTheme.labelLarge?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'home.shell.role'.tr(
                  namedArgs: {'role': profile?.role ?? dash},
                ),
                textAlign: TextAlign.start,
                style: textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryContainer,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'home.shell.tenant'.tr(
                  namedArgs: {'tenant': profile?.tenantId ?? dash},
                ),
                textAlign: TextAlign.start,
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  color: AppColors.zinc500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
