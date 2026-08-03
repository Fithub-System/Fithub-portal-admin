import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/kinetic_tokens.dart';
import '../fixtures/members_stitch_fixtures.dart';

/// Table pagination strip matching Stitch Member Management.
class MembersRosterPagination extends StatelessWidget {
  const MembersRosterPagination({
    super.key,
    required this.visibleCount,
    required this.usingFixtures,
  });

  final int visibleCount;
  final bool usingFixtures;

  @override
  Widget build(BuildContext context) {
    final range = usingFixtures
        ? MembersStitchFixtures.paginationRangeFixture
        : '1-$visibleCount';
    final total = usingFixtures
        ? MembersStitchFixtures.paginationTotalFixture
        : visibleCount;

    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(32, 24, 32, 24),
      decoration: BoxDecoration(
        color: KineticTokens.surfaceContainerLow.withValues(alpha: 0.3),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF444933).withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: const Color(0xFFC4C9AC),
                  letterSpacing: 2,
                  fontSize: 11,
                ),
                children: [
                  TextSpan(text: 'members.pagination.showing'.tr()),
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: range,
                    style: const TextStyle(
                      color: KineticTokens.pureWhite,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(text: ' ${'members.pagination.of'.tr()} '),
                  TextSpan(
                    text: _formatTotal(total),
                    style: const TextStyle(
                      color: KineticTokens.pureWhite,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(text: ' ${'members.pagination.members'.tr()}'),
                ],
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PageChrome(icon: Icons.chevron_left),
              const SizedBox(width: 8),
              const _PageChrome(label: '1', active: true),
              const SizedBox(width: 8),
              const _PageChrome(label: '2'),
              const SizedBox(width: 8),
              const _PageChrome(label: '3'),
              const SizedBox(width: 8),
              _PageChrome(icon: Icons.chevron_right),
            ],
          ),
        ],
      ),
    );
  }
}

String _formatTotal(int total) {
  final s = total.toString();
  if (s.length <= 3) return s;
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    final fromEnd = s.length - i;
    if (i > 0 && fromEnd % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}

class _PageChrome extends StatelessWidget {
  const _PageChrome({this.label, this.icon, this.active = false});

  final String? label;
  final IconData? icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? KineticTokens.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: active
            ? null
            : Border.all(
                color: const Color(0xFF444933).withValues(alpha: 0.2),
              ),
      ),
      child: icon != null
          ? Icon(icon, size: 16, color: const Color(0xFFC4C9AC))
          : Text(
              label ?? '',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: active
                    ? KineticTokens.onPrimaryContainer
                    : KineticTokens.onSurface,
              ),
            ),
    );
  }
}

/// Sync Active / API V2.4 / copyright footer strip.
class MembersSyncFooter extends StatelessWidget {
  const MembersSyncFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.5,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(top: 16),
        child: Row(
          children: [
            _DotLabel(
              color: KineticTokens.primaryContainer,
              label: 'members.footer.sync_active'.tr(),
            ),
            const SizedBox(width: 32),
            _DotLabel(
              color: KineticTokens.secondaryContainer,
              label: 'members.footer.api_version'.tr(),
            ),
            const Spacer(),
            Text(
              'members.footer.copyright'.tr(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: const Color(0xFFC4C9AC),
                fontSize: 10,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotLabel extends StatelessWidget {
  const _DotLabel({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            letterSpacing: -0.2,
            fontSize: 11,
            color: KineticTokens.onSurface,
          ),
        ),
      ],
    );
  }
}
