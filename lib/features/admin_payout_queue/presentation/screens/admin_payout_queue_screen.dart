import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/kinetic_tokens.dart';
import '../../domain/entities/coach_payout_request.dart';
import '../bloc/admin_payout_queue_bloc.dart';
import '../widgets/payout_filter_chips.dart';
import '../widgets/payout_kpi_strip.dart';
import '../widgets/payout_queue_table.dart';

/// FEAT-30 Admin Payout Queue — Stitch EN/AR.
///
/// EN `405663d1534848d2a96f1db4e76c35df` ·
/// AR `142d4cb868ff4aff8c040453bad737f9`.
class AdminPayoutQueueScreen extends StatefulWidget {
  const AdminPayoutQueueScreen({super.key, required this.canWrite});

  final bool canWrite;

  static const String stitchScreenIdEn = '405663d1534848d2a96f1db4e76c35df';
  static const String stitchScreenIdAr = '142d4cb868ff4aff8c040453bad737f9';
  static const String stitchScreenTitle = 'Admin Payout Queue';
  static const String brandLockDsAsset = 'assets/12737976743993098844';

  @override
  State<AdminPayoutQueueScreen> createState() => _AdminPayoutQueueScreenState();
}

class _AdminPayoutQueueScreenState extends State<AdminPayoutQueueScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminPayoutQueueBloc>().add(
          const AdminPayoutQueueLoadRequested(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.locale.languageCode == 'ar';
    final stitchId = isAr
        ? AdminPayoutQueueScreen.stitchScreenIdAr
        : AdminPayoutQueueScreen.stitchScreenIdEn;

    return ColoredBox(
      color: KineticTokens.stitchBackground,
      child: BlocConsumer<AdminPayoutQueueBloc, AdminPayoutQueueState>(
        listenWhen: (prev, next) =>
            prev.messageKey != next.messageKey && next.messageKey != null,
        listener: (context, state) {
          final key = state.messageKey;
          if (key == null) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(key.tr())),
          );
          context
              .read<AdminPayoutQueueBloc>()
              .add(const AdminPayoutQueueMessageCleared());
        },
        builder: (context, state) {
          if ((state.status == AdminPayoutQueueStatus.initial ||
                  state.status == AdminPayoutQueueStatus.loading) &&
              state.requests.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: KineticTokens.electricLime,
              ),
            );
          }

          if (state.status == AdminPayoutQueueStatus.failure &&
              state.requests.isEmpty) {
            return _ErrorBody(
              messageKey: state.messageKey ?? 'payouts.error.unknown',
              onRetry: () => context
                  .read<AdminPayoutQueueBloc>()
                  .add(const AdminPayoutQueueLoadRequested()),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              return ListView(
                padding: const EdgeInsetsDirectional.fromSTEB(40, 32, 40, 40),
                children: [
                  _Header(stitchId: stitchId),
                  const SizedBox(height: 28),
                  PayoutFilterChips(
                    selected: state.filter,
                    onSelected: (filter) => context
                        .read<AdminPayoutQueueBloc>()
                        .add(AdminPayoutQueueFilterChanged(filter)),
                  ),
                  const SizedBox(height: 24),
                  PayoutKpiStrip(
                    pending: state.pendingCount,
                    paidToday: state.paidTodayCount,
                    rejectedToday: state.rejectedTodayCount,
                  ),
                  const SizedBox(height: 28),
                  PayoutQueueTable(
                    rows: state.filteredRequests,
                    canWrite: widget.canWrite,
                    busyRequestId: state.busyRequestId,
                    currencyFormat: _amountFormat(context),
                    onMarkPaid: (id) => context.read<AdminPayoutQueueBloc>().add(
                          AdminPayoutQueueFulfillRequested(
                            requestId: id,
                            action: AdminPayoutFulfillAction.paid,
                            canWrite: widget.canWrite,
                          ),
                        ),
                    onReject: (id) => context.read<AdminPayoutQueueBloc>().add(
                          AdminPayoutQueueFulfillRequested(
                            requestId: id,
                            action: AdminPayoutFulfillAction.rejected,
                            canWrite: widget.canWrite,
                          ),
                        ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'payouts.footer.ops_only'.tr(),
                    style: const TextStyle(
                      color: KineticTokens.zincGray,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  NumberFormat _amountFormat(BuildContext context) {
    return NumberFormat.currency(
      locale: context.locale.toString(),
      symbol: '',
      decimalDigits: 2,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.stitchId});

  final String stitchId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'payouts.header.title'.tr(),
          style: const TextStyle(
            fontFamily: 'Lexend',
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: KineticTokens.onSurface,
            height: 1.1,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'payouts.header.subtitle'.tr(),
          style: const TextStyle(
            fontSize: 14,
            color: KineticTokens.zincGray,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Stitch $stitchId',
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF525252),
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.messageKey, required this.onRetry});

  final String messageKey;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              messageKey.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: KineticTokens.onSurface),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: KineticTokens.electricLime,
                foregroundColor: KineticTokens.deepCharcoal,
              ),
              child: Text('payouts.actions.retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
