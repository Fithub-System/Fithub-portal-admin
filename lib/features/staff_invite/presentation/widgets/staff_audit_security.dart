import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:fithub_portal_admin/config/theme/app_colors.dart';
import 'package:fithub_portal_admin/features/staff_invite/presentation/fixtures/staff_stitch_fixtures.dart';

/// Recent Audit Actions bento (§4.1 fixtures).
class StaffAuditFeed extends StatelessWidget {
  const StaffAuditFeed({super.key});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history, color: AppColors.secondary, size: 22),
              const SizedBox(width: 8),
              Text(
                'staff_invite.audit.title'.tr(),
                style: textTheme.labelLarge?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          for (final item in StaffStitchFixtures.auditItems) ...[
            _AuditItem(title: item.title, meta: item.meta),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
}

class _AuditItem extends StatelessWidget {
  const _AuditItem({required this.title, required this.meta});

  final String title;
  final String meta;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsetsDirectional.only(start: 4),
          padding: const EdgeInsetsDirectional.only(start: 16),
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: AppColors.outlineVariant, width: 1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                meta.toUpperCase(),
                style: textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  letterSpacing: 1,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        PositionedDirectional(
          start: 0,
          top: 4,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.outlineVariant,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

/// Security Compliance lime tile (§4.1 decorative chrome).
class StaffSecurityComplianceTile extends StatelessWidget {
  const StaffSecurityComplianceTile({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -48,
            bottom: -48,
            child: Icon(
              Icons.security,
              size: 200,
              color: AppColors.onPrimaryContainer.withValues(alpha: 0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'staff_invite.security.title'.tr(),
                style: textTheme.titleLarge?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                  color: AppColors.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 200),
                child: Text(
                  'staff_invite.security.body'.tr(),
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onPrimaryContainer.withValues(alpha: 0.8),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Icon(
                    Icons.verified,
                    size: 16,
                    color: AppColors.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'staff_invite.security.badge'.tr(),
                    style: textTheme.labelSmall?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: AppColors.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
