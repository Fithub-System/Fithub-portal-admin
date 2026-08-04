import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/kinetic_tokens.dart';
import '../fixtures/overview_stitch_fixtures.dart';

/// Stitch Expiring Memberships table (Overview mid col-span-8).
///
/// §4.1: ships Marcus / Elena fixture rows when expiry API unbound. Live rows
/// of the same structure replace fixtures when Backend binds.
class ExpiringMembershipsCard extends StatelessWidget {
  const ExpiringMembershipsCard({super.key, this.rows});

  /// Live expiry rows when bound; null/empty → Stitch fixtures.
  final List<OverviewExpiringRow>? rows;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final displayRows =
        (rows != null && rows!.isNotEmpty)
            ? rows!
            : OverviewStitchFixtures.expiringRows;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: KineticTokens.surfaceContainerLow,
        borderRadius: BorderRadius.circular(KineticTokens.dashboardCardRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.all(32),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'dashboard.expiring.title'.tr(),
                        textAlign: TextAlign.start,
                        style: textTheme.titleLarge?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: KineticTokens.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'dashboard.expiring.subtitle'.tr(),
                        textAlign: TextAlign.start,
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 12,
                          color: KineticTokens.zincGray,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: KineticTokens.primaryContainer,
                    disabledForegroundColor: KineticTokens.primaryContainer
                        .withValues(alpha: 0.7),
                    side: BorderSide(
                      color: KineticTokens.primaryContainer.withValues(
                        alpha: 0.2,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                  child: Text('dashboard.expiring.renew_all'.tr()),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: KineticTokens.pureWhite.withValues(alpha: 0.05),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        'dashboard.expiring.col_member'.tr(),
                        style: _headerStyle(textTheme),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'dashboard.expiring.col_plan'.tr(),
                        textAlign: TextAlign.center,
                        style: _headerStyle(textTheme),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'dashboard.expiring.col_expiration'.tr(),
                        textAlign: TextAlign.end,
                        style: _headerStyle(textTheme),
                      ),
                    ),
                    const SizedBox(width: 32),
                  ],
                ),
                const SizedBox(height: 8),
                for (var i = 0; i < displayRows.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: KineticTokens.pureWhite.withValues(alpha: 0.05),
                    ),
                  _ExpiringRowTile(row: displayRows[i]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextStyle? _headerStyle(TextTheme textTheme) {
    return textTheme.labelSmall?.copyWith(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.6,
      color: KineticTokens.zincGray,
    );
  }
}

class _ExpiringRowTile extends StatelessWidget {
  const _ExpiringRowTile({required this.row});

  final OverviewExpiringRow row;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dateColor =
        row.urgent ? KineticTokens.stitchError : KineticTokens.onSurface;
    final relativeColor = row.urgent
        ? KineticTokens.stitchError.withValues(alpha: 0.6)
        : KineticTokens.zincGray;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF262626),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _initials(row.fullName),
                    style: textTheme.labelSmall?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: KineticTokens.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        row.fullName,
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: KineticTokens.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        row.email,
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 12,
                          color: KineticTokens.zincGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF262626),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  row.planLabel,
                  textAlign: TextAlign.center,
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFD4D4D4),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  row.expirationDate,
                  textAlign: TextAlign.end,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: dateColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  row.relativeLabel,
                  textAlign: TextAlign.end,
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    color: relativeColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 32,
            child: Icon(
              Icons.more_vert,
              size: 20,
              color: KineticTokens.zincGray.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  static String _initials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}
