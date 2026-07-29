import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/kinetic_tokens.dart';
import '../../../access_scanner/domain/entities/member_roster_entry.dart';
import '../../../memberships/presentation/widgets/memberships_plans_panel.dart';

/// Enrolled athletes roster table (Plan Type from Drift cache).
class MemberRosterTable extends StatelessWidget {
  const MemberRosterTable({
    super.key,
    required this.members,
    required this.canWrite,
  });

  final List<MemberRosterEntry> members;
  final bool canWrite;

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

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingTextStyle: textTheme.labelLarge?.copyWith(
          color: KineticTokens.zincGray,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
        dataTextStyle: textTheme.bodyMedium?.copyWith(
          color: KineticTokens.pureWhite,
        ),
        columns: [
          DataColumn(label: Text('members.column.name'.tr())),
          DataColumn(label: Text('members.column.plan_type'.tr())),
          DataColumn(label: Text('members.column.status'.tr())),
          DataColumn(label: Text('members.column.actions'.tr())),
        ],
        rows: members.map((member) => _buildRow(context, member)).toList(),
      ),
    );
  }

  DataRow _buildRow(BuildContext context, MemberRosterEntry member) {
    final planLabel =
        member.membershipPlanName ?? 'members.plan_type.none'.tr();
    final statusLabel = _statusLabel(member.membershipStatus);

    return DataRow(
      cells: [
        DataCell(Text(member.fullName)),
        DataCell(Text(planLabel)),
        DataCell(Text(statusLabel)),
        DataCell(
          Wrap(
            spacing: 8,
            children: [
              if (canWrite)
                TextButton(
                  onPressed: () => MembershipsPlansPanel.showAssignSheet(
                    context,
                    initialAthleteId: member.id,
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
