import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/kinetic_tokens.dart';
import '../../../access_scanner/domain/entities/member_roster_entry.dart';
import '../../../memberships/presentation/widgets/memberships_plans_panel.dart';
import '../fixtures/members_stitch_fixtures.dart';

/// Stitch Active Roster table — name / plan chip / XP / actions.
class MemberRosterTable extends StatelessWidget {
  const MemberRosterTable({
    super.key,
    required this.members,
    required this.canWrite,
  });

  final List<MemberRosterEntry> members;
  final bool canWrite;

  static const double _minTableWidth = 860;

  @override
  Widget build(BuildContext context) {
    assert(
      members.isNotEmpty,
      '§4.1: roster table must never render empty — use Stitch fixtures',
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = constraints.maxWidth < _minTableWidth
            ? _minTableWidth
            : constraints.maxWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: tableWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeaderRow(),
                for (final member in members)
                  _MemberRow(member: member, canWrite: canWrite),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeaderRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: const Color(0xFFC4C9AC),
      letterSpacing: 2,
      fontSize: 11,
      fontWeight: FontWeight.w500,
    );
    return Container(
      color: KineticTokens.surfaceContainerHigh.withValues(alpha: 0.5),
      padding: const EdgeInsetsDirectional.fromSTEB(32, 20, 24, 20),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text('members.column.name'.tr(), style: style)),
          Expanded(
            flex: 2,
            child: Text('members.column.plan_type'.tr(), style: style),
          ),
          Expanded(
            flex: 3,
            child: Text('members.column.xp_level'.tr(), style: style),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'members.column.actions'.tr(),
              style: style,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.member, required this.canWrite});

  final MemberRosterEntry member;
  final bool canWrite;

  @override
  Widget build(BuildContext context) {
    final kind = membersPlanChipKind(member.membershipPlanName);
    final xp = member.powerScore.clamp(0, 100);
    final initials = membersInitials(member.fullName);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: const Color(0xFF444933).withValues(alpha: 0.1),
          ),
        ),
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(32, 20, 24, 20),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                _InitialsAvatar(initials: initials, kind: kind),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: KineticTokens.pureWhite,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        membersDisplayId(member),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFFC4C9AC),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(flex: 2, child: _PlanChip(kind: kind, label: _planLabel(kind))),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                SizedBox(
                  width: 128,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: SizedBox(
                      height: 6,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          const ColoredBox(color: Color(0xFF353534)),
                          FractionallySizedBox(
                            widthFactor: xp / 100,
                            alignment: AlignmentDirectional.centerStart,
                            child: const DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    KineticTokens.primaryContainer,
                                    KineticTokens.secondaryContainer,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$xp',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: KineticTokens.pureWhite,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: _ActionsCell(canWrite: canWrite, athleteId: member.id),
          ),
        ],
      ),
    );
  }

  String _planLabel(MembersPlanChipKind kind) {
    switch (kind) {
      case MembersPlanChipKind.elite:
        return 'members.plan_chip.elite'.tr();
      case MembersPlanChipKind.standard:
        return 'members.plan_chip.standard'.tr();
      case MembersPlanChipKind.basic:
        return 'members.plan_chip.basic'.tr();
      case MembersPlanChipKind.unknown:
        final name = member.membershipPlanName;
        if (name != null && name.isNotEmpty) return name.toUpperCase();
        return 'members.plan_chip.standard'.tr();
    }
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.initials, required this.kind});

  final String initials;
  final MembersPlanChipKind kind;

  @override
  Widget build(BuildContext context) {
    final Color ink = switch (kind) {
      MembersPlanChipKind.elite => KineticTokens.primaryContainer,
      MembersPlanChipKind.standard => KineticTokens.secondaryContainer,
      MembersPlanChipKind.basic => const Color(0xFFA3A3A3),
      MembersPlanChipKind.unknown => KineticTokens.primaryContainer,
    };
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF353534),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: ink,
          fontWeight: FontWeight.w900,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _PlanChip extends StatelessWidget {
  const _PlanChip({required this.kind, required this.label});

  final MembersPlanChipKind kind;
  final String label;

  @override
  Widget build(BuildContext context) {
    final (Color fg, Color bg, Color border) = switch (kind) {
      MembersPlanChipKind.elite => (
        KineticTokens.primaryContainer,
        KineticTokens.primaryContainer.withValues(alpha: 0.1),
        KineticTokens.primaryContainer.withValues(alpha: 0.2),
      ),
      MembersPlanChipKind.standard => (
        KineticTokens.secondaryContainer,
        KineticTokens.secondaryContainer.withValues(alpha: 0.1),
        KineticTokens.secondaryContainer.withValues(alpha: 0.2),
      ),
      MembersPlanChipKind.basic || MembersPlanChipKind.unknown => (
        const Color(0xFFA3A3A3),
        const Color(0xFF262626),
        const Color(0xFF404040),
      ),
    };

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 12,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: fg,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

class _ActionsCell extends StatelessWidget {
  const _ActionsCell({required this.canWrite, required this.athleteId});

  final bool canWrite;
  final String athleteId;

  @override
  Widget build(BuildContext context) {
    final muted = TextStyle(
      color: const Color(0xFFC4C9AC),
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
    );

    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerEnd,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: null,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFC4C9AC),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: Text('members.action.freeze'.tr(), style: muted),
            ),
            TextButton(
              onPressed: null,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFC4C9AC),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: Text('members.action.renew'.tr(), style: muted),
            ),
            const SizedBox(width: 4),
            Material(
              color: const Color(0xFF353534),
              borderRadius: BorderRadius.circular(4),
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: canWrite
                    ? () => MembershipsPlansPanel.showAssignSheet(
                        context,
                        initialAthleteId: athleteId,
                      )
                    : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Text(
                    'members.action.full_evaluation'.tr(),
                    style: muted.copyWith(color: KineticTokens.onSurface),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
