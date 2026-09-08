import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/kinetic_tokens.dart';
import '../../../access_scanner/domain/entities/member_roster_entry.dart';
import '../../../auth/presentation/widgets/stitch_auth_snackbar.dart';
import '../../../memberships/domain/entities/freeze_policy.dart';
import '../../../memberships/presentation/cubit/memberships_cubit.dart';
import '../../../memberships/presentation/widgets/memberships_plans_panel.dart';
import '../cubit/member_roster_cubit.dart';
import '../fixtures/members_stitch_fixtures.dart';

/// Stitch Active Roster table — name / plan chip / XP / actions.
class MemberRosterTable extends StatelessWidget {
  const MemberRosterTable({
    super.key,
    required this.members,
    required this.canAssign,
    required this.canRenew,
    required this.canFreeze,
  });

  final List<MemberRosterEntry> members;

  /// FEAT-07 Admin-only assign.
  final bool canAssign;

  /// FEAT-61 Admin-only renew.
  final bool canRenew;

  /// FEAT-61 Admin + Receptionist freeze/unfreeze.
  final bool canFreeze;

  static const double _minTableWidth = 860;

  @override
  Widget build(BuildContext context) {
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
                  _MemberRow(
                    member: member,
                    canAssign: canAssign,
                    canRenew: canRenew,
                    canFreeze: canFreeze,
                  ),
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
  const _MemberRow({
    required this.member,
    required this.canAssign,
    required this.canRenew,
    required this.canFreeze,
  });

  final MemberRosterEntry member;
  final bool canAssign;
  final bool canRenew;
  final bool canFreeze;

  @override
  Widget build(BuildContext context) {
    final kind = membersPlanChipKind(member.membershipPlanName);
    final label = membersPlanChipLabel(member.membershipPlanName);
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
          Expanded(flex: 2, child: _PlanChip(kind: kind, label: label)),
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
            child: _ActionsCell(
              member: member,
              canAssign: canAssign,
              canRenew: canRenew,
              canFreeze: canFreeze,
            ),
          ),
        ],
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.initials, required this.kind});

  final String initials;
  final MembersPlanChipKind kind;

  @override
  Widget build(BuildContext context) {
    final Color ink = switch (kind) {
      MembersPlanChipKind.named => KineticTokens.secondaryContainer,
      MembersPlanChipKind.none => const Color(0xFFA3A3A3),
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
      MembersPlanChipKind.named => (
        KineticTokens.secondaryContainer,
        KineticTokens.secondaryContainer.withValues(alpha: 0.1),
        KineticTokens.secondaryContainer.withValues(alpha: 0.2),
      ),
      MembersPlanChipKind.none => (
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: fg,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class _ActionsCell extends StatelessWidget {
  const _ActionsCell({
    required this.member,
    required this.canAssign,
    required this.canRenew,
    required this.canFreeze,
  });

  final MemberRosterEntry member;
  final bool canAssign;
  final bool canRenew;
  final bool canFreeze;

  @override
  Widget build(BuildContext context) {
    final muted = TextStyle(
      color: const Color(0xFFC4C9AC),
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
    );
    final active = muted.copyWith(color: KineticTokens.primaryContainer);

    final memberships = context.watch<MembershipsCubit>().state;
    final policy = resolveFreezePolicy(
      memberships.freezePolicies,
      member.membershipPlanId,
    );
    final freezeEnabled =
        canFreeze &&
        member.membershipId != null &&
        member.hasActiveMembership &&
        policy != null;
    final unfreezeEnabled =
        canFreeze &&
        member.membershipId != null &&
        member.hasPausedMembership;
    final renewEnabled = canRenew && member.canRenewMembership;

    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerEnd,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (member.hasPausedMembership)
              TextButton(
                onPressed: unfreezeEnabled
                    ? () => _confirmUnfreeze(context, member)
                    : null,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFC4C9AC),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: Text(
                  'members.action.unfreeze'.tr(),
                  style: unfreezeEnabled ? active : muted,
                ),
              )
            else
              TextButton(
                onPressed: freezeEnabled
                    ? () => _confirmFreeze(context, member, policy)
                    : null,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFC4C9AC),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: Text(
                  'members.action.freeze'.tr(),
                  style: freezeEnabled ? active : muted,
                ),
              ),
            TextButton(
              onPressed: renewEnabled
                  ? () => _confirmRenew(context, member)
                  : null,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFC4C9AC),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: Text(
                'members.action.renew'.tr(),
                style: renewEnabled ? active : muted,
              ),
            ),
            const SizedBox(width: 4),
            Material(
              color: const Color(0xFF353534),
              borderRadius: BorderRadius.circular(4),
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: canAssign
                    ? () => MembershipsPlansPanel.showAssignSheet(
                        context,
                        initialAthleteId: member.id,
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

  Future<void> _confirmRenew(
    BuildContext context,
    MemberRosterEntry member,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: KineticTokens.surfaceContainerLow,
        title: Text(
          'members.renew.confirm_title'.tr(),
          style: const TextStyle(color: KineticTokens.pureWhite),
        ),
        content: Text(
          'members.renew.confirm_body'.tr(
            namedArgs: {'name': member.fullName},
          ),
          style: const TextStyle(color: KineticTokens.zincGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('members.dialog.cancel'.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('members.action.renew'.tr()),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final membershipId = member.membershipId;
    if (membershipId == null) return;

    final key = await context.read<MembershipsCubit>().renewMembership(
      membershipId,
    );
    if (!context.mounted) return;
    StitchAuthSnackbar.show(context, key.tr());
    if (key.startsWith('members.success')) {
      await context.read<MemberRosterCubit>().refreshFromCloud();
    }
  }

  Future<void> _confirmFreeze(
    BuildContext context,
    MemberRosterEntry member,
    FreezePolicy policy,
  ) async {
    final daysController = TextEditingController(
      text: '${policy.freezeDays}',
    );
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: KineticTokens.surfaceContainerLow,
        title: Text(
          'members.freeze.confirm_title'.tr(),
          style: const TextStyle(color: KineticTokens.pureWhite),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'members.freeze.confirm_body'.tr(
                namedArgs: {'name': member.fullName},
              ),
              style: const TextStyle(color: KineticTokens.zincGray),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: daysController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: KineticTokens.pureWhite),
              decoration: InputDecoration(
                labelText: 'members.freeze.days_label'.tr(),
                helperText: 'members.freeze.days_helper'.tr(
                  namedArgs: {
                    'max': '${policy.maxFreezeDaysPerTime}',
                  },
                ),
                helperMaxLines: 2,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('members.dialog.cancel'.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('members.action.freeze'.tr()),
          ),
        ],
      ),
    );
    final rawDays = int.tryParse(daysController.text.trim());
    daysController.dispose();
    if (ok != true || !context.mounted) return;
    final membershipId = member.membershipId;
    if (membershipId == null) return;

    if (rawDays == null ||
        rawDays < 0 ||
        rawDays > policy.maxFreezeDaysPerTime) {
      StitchAuthSnackbar.show(
        context,
        'members.error.freeze_days_invalid'.tr(
          namedArgs: {'max': '${policy.maxFreezeDaysPerTime}'},
        ),
      );
      return;
    }

    final key = await context.read<MembershipsCubit>().freezeMembership(
      membershipId: membershipId,
      days: rawDays,
    );
    if (!context.mounted) return;
    StitchAuthSnackbar.show(context, key.tr());
    if (key.startsWith('members.success')) {
      await context.read<MemberRosterCubit>().refreshFromCloud();
    }
  }

  Future<void> _confirmUnfreeze(
    BuildContext context,
    MemberRosterEntry member,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: KineticTokens.surfaceContainerLow,
        title: Text(
          'members.unfreeze.confirm_title'.tr(),
          style: const TextStyle(color: KineticTokens.pureWhite),
        ),
        content: Text(
          'members.unfreeze.confirm_body'.tr(
            namedArgs: {'name': member.fullName},
          ),
          style: const TextStyle(color: KineticTokens.zincGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('members.dialog.cancel'.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('members.action.unfreeze'.tr()),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final membershipId = member.membershipId;
    if (membershipId == null) return;

    final key = await context.read<MembershipsCubit>().unfreezeMembership(
      membershipId,
    );
    if (!context.mounted) return;
    StitchAuthSnackbar.show(context, key.tr());
    if (key.startsWith('members.success')) {
      await context.read<MemberRosterCubit>().refreshFromCloud();
    }
  }
}
