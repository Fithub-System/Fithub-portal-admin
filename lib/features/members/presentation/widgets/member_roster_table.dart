import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/kinetic_tokens.dart';
import '../../../access_scanner/domain/entities/member_roster_entry.dart';
import '../../../memberships/presentation/widgets/memberships_plans_panel.dart';

/// Enrolled athletes roster table (Plan Type from Drift cache).
///
/// Fills available width; scrolls horizontally only when content needs more
/// than the viewport (avoids clipped / overflowing action cells).
class MemberRosterTable extends StatelessWidget {
  const MemberRosterTable({
    super.key,
    required this.members,
    required this.canWrite,
  });

  final List<MemberRosterEntry> members;
  final bool canWrite;

  /// Minimum content width before horizontal scroll kicks in.
  static const double _minTableWidth = 720;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (members.isEmpty) {
      return Padding(
        padding: const EdgeInsetsDirectional.all(24),
        child: Text(
          'members.empty_roster'.tr(),
          style: textTheme.bodyMedium?.copyWith(color: KineticTokens.zincGray),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const horizontalInset = 32.0; // 16 leading + 16 trailing
        final viewport = constraints.maxWidth - horizontalInset;
        final tableWidth = viewport < _minTableWidth
            ? _minTableWidth
            : viewport;

        return Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 24),
            child: Scrollbar(
              thumbVisibility: viewport < _minTableWidth,
              notificationPredicate: (notification) => notification.depth == 1,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: DataTable(
                    columnSpacing: 24,
                    horizontalMargin: 12,
                    headingTextStyle: textTheme.labelLarge?.copyWith(
                      color: KineticTokens.zincGray,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                    dataTextStyle: textTheme.bodyMedium?.copyWith(
                      color: KineticTokens.pureWhite,
                    ),
                    dataRowMinHeight: 56,
                    dataRowMaxHeight: 72,
                    columns: [
                      DataColumn(label: Text('members.column.name'.tr())),
                      DataColumn(label: Text('members.column.plan_type'.tr())),
                      DataColumn(label: Text('members.column.status'.tr())),
                      DataColumn(label: Text('members.column.actions'.tr())),
                    ],
                    rows: members
                        .map((member) => _buildRow(context, member))
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  DataRow _buildRow(BuildContext context, MemberRosterEntry member) {
    final planLabel =
        member.membershipPlanName ?? 'members.plan_type.none'.tr();
    final statusLabel = _statusLabel(member.membershipStatus);

    return DataRow(
      cells: [
        DataCell(
          Text(member.fullName, overflow: TextOverflow.ellipsis, maxLines: 1),
        ),
        DataCell(Text(planLabel, overflow: TextOverflow.ellipsis, maxLines: 1)),
        DataCell(
          Text(statusLabel, overflow: TextOverflow.ellipsis, maxLines: 1),
        ),
        DataCell(_ActionsCell(canWrite: canWrite, athleteId: member.id)),
      ],
    );
  }

  String _statusLabel(String? status) {
    if (status == null || status.isEmpty) {
      return 'members.status.none'.tr();
    }
    switch (status.toLowerCase()) {
      case 'active':
        return 'access_scanner.success.active_badge'.tr();
      case 'expired':
        return 'access_scanner.success.expired_badge'.tr();
      case 'paused':
        return 'access_scanner.success.paused_badge'.tr();
      case 'cancelled':
        return 'access_scanner.success.cancelled_badge'.tr();
      default:
        return status;
    }
  }
}

class _ActionsCell extends StatelessWidget {
  const _ActionsCell({required this.canWrite, required this.athleteId});

  final bool canWrite;
  final String athleteId;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerStart,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (canWrite)
              TextButton(
                onPressed: () => MembershipsPlansPanel.showAssignSheet(
                  context,
                  initialAthleteId: athleteId,
                ),
                child: Text('memberships.cta.assign'.tr()),
              ),
            TextButton(
              onPressed: null,
              child: Text('members.action.freeze'.tr()),
            ),
            TextButton(
              onPressed: null,
              child: Text('members.action.renew'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
