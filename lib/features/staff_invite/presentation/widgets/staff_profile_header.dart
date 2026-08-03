import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:fithub_portal_admin/config/theme/app_colors.dart';
import 'package:fithub_portal_admin/features/staff_invite/presentation/fixtures/staff_stitch_fixtures.dart';

/// Page header: title + subtitle + Active Shifts chip.
class StaffProfileHeader extends StatelessWidget {
  const StaffProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(color: AppColors.primaryContainer, width: 4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.only(start: 32, top: 8, bottom: 8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final stack = constraints.maxWidth < 720;
            final titleBlock = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'staff_invite.title'.tr(),
                  style: textTheme.headlineMedium?.copyWith(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.5,
                    height: 1.05,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'staff_invite.subtitle'.tr(),
                  style: textTheme.bodyLarge?.copyWith(
                    fontSize: 18,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            );
            final chip = const StaffActiveShiftsChip();
            if (stack) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  titleBlock,
                  const SizedBox(height: 16),
                  chip,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: titleBlock),
                const SizedBox(width: 24),
                chip,
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Stitch Active Shifts badge (`14` fixture until Backend binds).
class StaffActiveShiftsChip extends StatelessWidget {
  const StaffActiveShiftsChip({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'staff_invite.active_shifts'.tr(),
            style: textTheme.labelSmall?.copyWith(
              fontSize: 11,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            StaffStitchFixtures.activeShiftsValue,
            style: textTheme.titleLarge?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
