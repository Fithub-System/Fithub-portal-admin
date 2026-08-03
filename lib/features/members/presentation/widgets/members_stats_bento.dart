import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/kinetic_tokens.dart';
import '../../../access_scanner/domain/entities/member_roster_entry.dart';
import '../fixtures/members_stitch_fixtures.dart';

/// Stitch 4-tile stats bento above the roster table.
class MembersStatsBento extends StatelessWidget {
  const MembersStatsBento({
    super.key,
    required this.members,
    required this.usingFixtures,
  });

  final List<MemberRosterEntry> members;
  final bool usingFixtures;

  @override
  Widget build(BuildContext context) {
    final eliteCount = usingFixtures
        ? MembersStitchFixtures.eliteTierValue
        : members
              .where(
                (m) =>
                    membersPlanChipKind(m.membershipPlanName) ==
                    MembersPlanChipKind.elite,
              )
              .length
              .toString();

    final avgXp = usingFixtures
        ? MembersStitchFixtures.avgXpValue
        : members.isEmpty
        ? '0'
        : (members.map((m) => m.powerScore).reduce((a, b) => a + b) /
                  members.length)
              .toStringAsFixed(1);

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 720;
        final tiles = [
          _StatTile(
            labelKey: 'members.stats.elite_tier',
            value: eliteCount,
            accentBorder: true,
          ),
          _StatTile(
            labelKey: 'members.stats.avg_xp',
            value: avgXp,
          ),
          _StatTile(
            labelKey: 'members.stats.active_sessions',
            value: MembersStitchFixtures.activeSessionsValue,
          ),
          _StatTile(
            labelKey: 'members.stats.system_health',
            value: 'members.stats.system_health_value'.tr(),
            fill: KineticTokens.secondaryContainer,
            labelColor: const Color(0xFF00285B),
            valueColor: const Color(0xFF00285B),
          ),
        ];

        if (!wide) {
          return Column(
            children: [
              for (var i = 0; i < tiles.length; i++) ...[
                tiles[i],
                if (i < tiles.length - 1) const SizedBox(height: 16),
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < tiles.length; i++) ...[
              Expanded(child: tiles[i]),
              if (i < tiles.length - 1) const SizedBox(width: 16),
            ],
          ],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.labelKey,
    required this.value,
    this.accentBorder = false,
    this.fill = KineticTokens.surfaceContainerLow,
    this.labelColor = const Color(0xFFC4C9AC),
    this.valueColor = KineticTokens.pureWhite,
  });

  final String labelKey;
  final String value;
  final bool accentBorder;
  final Color fill;
  final Color labelColor;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.all(24),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(KineticTokens.dashboardCardRadius),
        border: accentBorder
            ? const BorderDirectional(
                start: BorderSide(
                  color: KineticTokens.primaryContainer,
                  width: 4,
                ),
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelKey.tr(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: labelColor,
              fontWeight: FontWeight.w500,
              letterSpacing: 2,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w700,
              fontSize: 30,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
