import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
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
                      'Welcome, ${profile?.name ?? 'Admin'}',
                      style: GoogleFonts.lexend(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.pureWhite,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Sign out',
                    onPressed: () => context.read<AuthBloc>().add(
                          const AuthSignOutRequested(),
                        ),
                    icon: const Icon(Icons.logout, color: AppColors.zinc500),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'COMMAND CENTER',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Role: ${profile?.role ?? '—'}',
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryContainer,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tenant: ${profile?.tenantId ?? '—'}',
                style: GoogleFonts.inter(
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
