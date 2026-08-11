import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/kinetic_tokens.dart';
import '../bloc/admin_payout_queue_bloc.dart';

class PayoutFilterChips extends StatelessWidget {
  const PayoutFilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final AdminPayoutFilter selected;
  final ValueChanged<AdminPayoutFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final items = <(AdminPayoutFilter, String)>[
      (AdminPayoutFilter.all, 'payouts.filter.all'),
      (AdminPayoutFilter.pending, 'payouts.filter.pending'),
      (AdminPayoutFilter.paid, 'payouts.filter.paid'),
      (AdminPayoutFilter.rejected, 'payouts.filter.rejected'),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final (filter, key) in items)
          _Chip(
            label: key.tr(),
            selected: selected == filter,
            onTap: () => onSelected(filter),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? KineticTokens.electricLime.withValues(alpha: 0.16)
          : KineticTokens.surfaceContainerLow,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Lexend',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: selected
                  ? KineticTokens.electricLime
                  : const Color(0xFFA3A3A3),
            ),
          ),
        ),
      ),
    );
  }
}
