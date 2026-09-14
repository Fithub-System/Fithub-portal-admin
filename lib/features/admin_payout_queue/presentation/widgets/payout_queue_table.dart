import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/kinetic_tokens.dart';
import '../../domain/entities/coach_payout_request.dart';

class PayoutQueueTable extends StatelessWidget {
  const PayoutQueueTable({
    super.key,
    required this.rows,
    required this.canWrite,
    required this.busyRequestId,
    required this.currencyFormat,
    required this.onApprove,
    required this.onBeginSettlement,
    required this.onRecordSettlement,
    required this.onReject,
  });

  final List<CoachPayoutRequest> rows;
  final bool canWrite;
  final String? busyRequestId;
  final NumberFormat currencyFormat;
  final ValueChanged<String> onApprove;
  final ValueChanged<String> onBeginSettlement;
  final ValueChanged<String> onRecordSettlement;
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
                onApprove: onApprove,
                onBeginSettlement: onBeginSettlement,
                onRecordSettlement: onRecordSettlement,
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
          _HeadCell('payouts.table.actions'.tr(), flex: 4),
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
    required this.onApprove,
    required this.onBeginSettlement,
    required this.onRecordSettlement,
    required this.onReject,
  });

  final CoachPayoutRequest request;
  final bool canWrite;
  final bool busy;
  final NumberFormat currencyFormat;
  final ValueChanged<String> onApprove;
  final ValueChanged<String> onBeginSettlement;
  final ValueChanged<String> onRecordSettlement;
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
            flex: 4,
            child: request.status.isOpen
                ? _ActionButtons(
                    status: request.status,
                    canWrite: canWrite,
                    busy: busy,
                    onApprove: () => onApprove(request.id),
                    onBeginSettlement: () => onBeginSettlement(request.id),
                    onRecordSettlement: () => onRecordSettlement(request.id),
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
      CoachPayoutRequestStatus.approved => (
          'payouts.status.approved',
          KineticTokens.electricLime,
        ),
      CoachPayoutRequestStatus.settling => (
          'payouts.status.settling',
          KineticTokens.secondaryContainer,
        ),
      CoachPayoutRequestStatus.settled ||
      CoachPayoutRequestStatus.paid => (
          'payouts.status.settled',
          KineticTokens.secondaryContainer,
        ),
      CoachPayoutRequestStatus.failed => (
          'payouts.status.failed',
          KineticTokens.peakCoral,
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
    required this.status,
    required this.canWrite,
    required this.busy,
    required this.onApprove,
    required this.onBeginSettlement,
    required this.onRecordSettlement,
    required this.onReject,
  });

  final CoachPayoutRequestStatus status;
  final bool canWrite;
  final bool busy;
  final VoidCallback onApprove;
  final VoidCallback onBeginSettlement;
  final VoidCallback onRecordSettlement;
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

    final primary = switch (status) {
      CoachPayoutRequestStatus.pending => (
          'payouts.actions.approve',
          onApprove,
        ),
      CoachPayoutRequestStatus.approved => (
          'payouts.actions.begin_settlement',
          onBeginSettlement,
        ),
      CoachPayoutRequestStatus.settling => (
          'payouts.actions.record_settlement',
          onRecordSettlement,
        ),
      _ => null,
    };

    final showReject = status == CoachPayoutRequestStatus.pending ||
        status == CoachPayoutRequestStatus.approved;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (primary != null)
          FilledButton(
            onPressed: busy ? null : primary.$2,
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
                    primary.$1.tr(),
                    style: const TextStyle(
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
          ),
        if (showReject)
          OutlinedButton(
            onPressed: busy ? null : onReject,
            style: OutlinedButton.styleFrom(
              foregroundColor: KineticTokens.peakCoral,
              side: const BorderSide(color: KineticTokens.peakCoral),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
