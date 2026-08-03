import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:fithub_portal_admin/config/theme/app_colors.dart';
import 'package:fithub_portal_admin/features/staff_invite/presentation/fixtures/staff_stitch_fixtures.dart';
import 'package:fithub_portal_admin/features/staff_invite/presentation/widgets/staff_shift_models.dart';

/// Shift Log: Real-Time Stream header + chrome CTAs.
class StaffShiftLogHeader extends StatelessWidget {
  const StaffShiftLogHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final stack = constraints.maxWidth < 640;
        final title = Row(
          children: [
            const Icon(
              Icons.schedule,
              color: AppColors.primaryContainer,
              size: 28,
            ),
            const SizedBox(width: 16),
            Flexible(
              child: Text(
                'staff_invite.shift_log.title'.tr(),
                style: textTheme.titleLarge?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        );
        final actions = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ChromeButton(label: 'staff_invite.shift_log.export'.tr()),
            const SizedBox(width: 8),
            _ChromeButton(label: 'staff_invite.shift_log.filter'.tr()),
          ],
        );
        if (stack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              const SizedBox(height: 12),
              actions,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: title),
            actions,
          ],
        );
      },
    );
  }
}

class _ChromeButton extends StatelessWidget {
  const _ChromeButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

/// Shift Log table with §4.1 fixture rows (never blank / bare —).
class StaffShiftLogTable extends StatelessWidget {
  const StaffShiftLogTable({super.key, this.rows});

  final List<StaffShiftFixtureRow>? rows;

  @override
  Widget build(BuildContext context) {
    final data = rows ?? StaffStitchFixtures.shiftRows;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 960),
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: const {
              0: FlexColumnWidth(2.4),
              1: FlexColumnWidth(1.1),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1),
              4: FlexColumnWidth(1),
              5: FlexColumnWidth(0.7),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                ),
                children: [
                  _HeaderCell('staff_invite.shift_log.col.member'.tr()),
                  _HeaderCell('staff_invite.shift_log.col.role'.tr()),
                  _HeaderCell(
                    'staff_invite.shift_log.col.clock_in'.tr(),
                    align: TextAlign.center,
                  ),
                  _HeaderCell(
                    'staff_invite.shift_log.col.clock_out'.tr(),
                    align: TextAlign.center,
                  ),
                  _HeaderCell(
                    'staff_invite.shift_log.col.hours'.tr(),
                    align: TextAlign.end,
                  ),
                  _HeaderCell(
                    'staff_invite.shift_log.col.status'.tr(),
                    align: TextAlign.end,
                  ),
                ],
              ),
              for (var i = 0; i < data.length; i++)
                TableRow(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  children: [
                    _MemberCell(row: data[i]),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 24,
                      ),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: _RoleChip(kind: data[i].role),
                      ),
                    ),
                    _MonoCell(data[i].clockIn, align: TextAlign.center),
                    _MonoCell(data[i].clockOut, align: TextAlign.center),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 24,
                      ),
                      child: Text(
                        data[i].totalHours,
                        textAlign: TextAlign.end,
                        style: textTheme.titleMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 24,
                      ),
                      child: Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: _StatusDot(onShift: data[i].onShift),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.label, {this.align = TextAlign.start});

  final String label;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: Text(
        label,
        textAlign: align,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _MonoCell extends StatelessWidget {
  const _MonoCell(this.value, {required this.align});

  final String value;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Text(
        value,
        textAlign: align,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 14,
          fontFamily: 'monospace',
          color: AppColors.onSurface,
        ),
      ),
    );
  }
}

class _MemberCell extends StatelessWidget {
  const _MemberCell({required this.row});

  final StaffShiftFixtureRow row;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bg = row.avatarAccent == StaffAvatarAccent.lime
        ? AppColors.primaryContainer
        : AppColors.surfaceContainerHighest;
    final fg = row.avatarAccent == StaffAvatarAccent.lime
        ? AppColors.onPrimaryContainer
        : AppColors.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              row.initials,
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: fg,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.fullName,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  row.email,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.kind});

  final StaffShiftRoleKind kind;

  @override
  Widget build(BuildContext context) {
    late final String key;
    late final Color fg;
    late final Color bg;
    switch (kind) {
      case StaffShiftRoleKind.trainer:
        key = 'staff_invite.role.coach.title';
        fg = AppColors.secondaryContainer;
        bg = AppColors.secondaryContainer.withValues(alpha: 0.1);
      case StaffShiftRoleKind.admin:
        key = 'staff_invite.role.admin.title';
        fg = AppColors.onSurfaceVariant;
        bg = AppColors.surfaceContainerHighest;
      case StaffShiftRoleKind.frontDesk:
        key = 'staff_invite.role.receptionist.title';
        fg = const Color(0xFFB6C9D8);
        bg = const Color(0xFFD2E5F5).withValues(alpha: 0.1);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        key.tr().toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
          color: fg,
        ),
      ),
    );
  }
}

class _StatusDot extends StatefulWidget {
  const _StatusDot({required this.onShift});

  final bool onShift;

  @override
  State<_StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<_StatusDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.onShift) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _StatusDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onShift && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.onShift && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.onShift) {
      return Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
      );
    }
    return FadeTransition(
      opacity: Tween<double>(begin: 0.35, end: 1).animate(_controller),
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.primaryContainer,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
