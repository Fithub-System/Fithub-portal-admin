import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../config/theme/kinetic_tokens.dart';
import '../../domain/entities/coach_payout_request.dart';

class PayoutQueueTable extends StatelessWidget {
  const PayoutQueueTable({
    super.key,
    required this.rows,
    required this.canWrite,
    required this.busyRequestId,
    required this.currencyFormat,
    required this.onMarkPaid,
    required this.onReject,
  });

  final List<CoachPayoutRequest> rows;
  final bool canWrite;
  final String? busyRequestId;
  final NumberFormat currencyFormat;
  final ValueChanged<String> onMarkPaid;
  final ValueChanged<String> onReject;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: KineticTokens.surfaceContainerLow,
        borderRadius: BorderRadius.circular(KineticTokens.dashboardCardRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _HeaderRow(),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.all(28),
              child: Text(
                'payouts.table.empty'.tr(),
                style: const TextStyle(color: KineticTokens.zincGray),
              ),
            )
          else
            for (final row in rows)
              _DataRow(
                request: row,
                canWrite: canWrite,
                busy: busyRequestId == row.id,
                currencyFormat: currencyFormat,
                onMarkPaid: onMarkPaid,
                onReject: onReject,
              ),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: KineticTokens.surfaceContainerLowest,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          _HeadCell('payouts.table.coach'.tr(), flex: 3),
          _HeadCell('payouts.table.amount'.tr(), flex: 2),
          _HeadCell('payouts.table.status'.tr(), flex: 2),
          _HeadCell('payouts.table.requested_at'.tr(), flex: 3),
          _HeadCell('payouts.table.actions'.tr(), flex: 3),
        ],
      ),
    );
  }
}

class _HeadCell extends StatelessWidget {
  const _HeadCell(this.label, {required this.flex});

  final String label;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'Lexend',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
          color: KineticTokens.zincGray,
        ),
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({
    required this.request,
    required this.canWrite,
    required this.busy,
    required this.currencyFormat,
    required this.onMarkPaid,
    required this.onReject,
  });

  final CoachPayoutRequest request;
  final bool canWrite;
  final bool busy;
  final NumberFormat currencyFormat;
  final ValueChanged<String> onMarkPaid;
  final ValueChanged<String> onReject;

  @override
  Widget build(BuildContext context) {
    final amount =
        '${currencyFormat.format(request.amountCents / 100)} ${request.currency}';
    final requested = DateFormat.yMMMd(
      context.locale.toString(),
    ).add_Hm().format(request.createdAt.toLocal());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFF262626), width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              request.coachDisplayName,
              style: const TextStyle(
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w600,
                color: KineticTokens.onSurface,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              amount.trim(),
              style: const TextStyle(
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w700,
                color: KineticTokens.onSurface,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: _StatusBadge(status: request.status),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              requested,
              style: const TextStyle(
                color: Color(0xFFA3A3A3),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: request.isPending
                ? _ActionButtons(
                    canWrite: canWrite,
                    busy: busy,
                    onMarkPaid: () => onMarkPaid(request.id),
                    onReject: () => onReject(request.id),
                  )
                : Text(
                    'payouts.table.no_actions'.tr(),
                    style: const TextStyle(
                      color: KineticTokens.zincGray,
                      fontSize: 12,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final CoachPayoutRequestStatus status;

  @override
  Widget build(BuildContext context) {
    final (labelKey, color) = switch (status) {
      CoachPayoutRequestStatus.pending => (
          'payouts.status.pending',
          KineticTokens.electricLime,
        ),
      CoachPayoutRequestStatus.paid => (
          'payouts.status.paid',
          KineticTokens.secondaryContainer,
        ),
      CoachPayoutRequestStatus.rejected => (
          'payouts.status.rejected',
          KineticTokens.peakCoral,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        labelKey.tr(),
        style: TextStyle(
          fontFamily: 'Lexend',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: color,
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.canWrite,
    required this.busy,
    required this.onMarkPaid,
    required this.onReject,
  });

  final bool canWrite;
  final bool busy;
  final VoidCallback onMarkPaid;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    if (!canWrite) {
      return Text(
        'payouts.table.read_only'.tr(),
        style: const TextStyle(
          color: KineticTokens.zincGray,
          fontSize: 12,
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilledButton(
          onPressed: busy ? null : onMarkPaid,
          style: FilledButton.styleFrom(
            backgroundColor: KineticTokens.electricLime,
            disabledBackgroundColor:
                KineticTokens.electricLime.withValues(alpha: 0.4),
            foregroundColor: KineticTokens.deepCharcoal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: busy
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  'payouts.actions.mark_paid'.tr(),
                  style: const TextStyle(
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
        ),
        OutlinedButton(
          onPressed: busy ? null : onReject,
          style: OutlinedButton.styleFrom(
            foregroundColor: KineticTokens.peakCoral,
            side: const BorderSide(color: KineticTokens.peakCoral),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: Text(
            'payouts.actions.reject'.tr(),
            style: const TextStyle(
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
