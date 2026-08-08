import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/kinetic_tokens.dart';
import '../../../auth/presentation/widgets/stitch_auth_snackbar.dart';
import '../../domain/entities/membership_charge.dart';
import '../cubit/billing_cubit.dart';

/// FEAT-08 charges list + Admin mark paid — secondary on Marketing rail
/// (FEAT-23 coexistence). Does not rip membership_charges.
class BillingChargesSection extends StatefulWidget {
  const BillingChargesSection({super.key, required this.canWrite});

  final bool canWrite;

  @override
  State<BillingChargesSection> createState() => _BillingChargesSectionState();
}

class _BillingChargesSectionState extends State<BillingChargesSection> {
  @override
  void initState() {
    super.initState();
    context.read<BillingCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<BillingCubit, BillingState>(
      listenWhen: (prev, next) =>
          next.messageKey != null && next.messageKey != prev.messageKey,
      listener: (context, state) {
        final key = state.messageKey;
        if (key == null || key.isEmpty) return;
        final named = <String, String>{};
        if (key == 'billing.success.freeze_applied' &&
            state.freezePausedCount != null) {
          named['count'] = '${state.freezePausedCount}';
        }
        StitchAuthSnackbar.show(
          context,
          named.isEmpty ? key.tr() : key.tr(namedArgs: named),
        );
      },
      builder: (context, state) {
        if (state.status == BillingStatus.loading ||
            state.status == BillingStatus.initial) {
          return const Padding(
            padding: EdgeInsetsDirectional.symmetric(vertical: 24),
            child: Center(
              child: CircularProgressIndicator(
                color: KineticTokens.electricLime,
              ),
            ),
          );
        }

        if (state.status == BillingStatus.failure && state.charges.isEmpty) {
          return Padding(
            padding: const EdgeInsetsDirectional.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (state.messageKey ?? 'billing.error.unknown').tr(),
                  style: textTheme.bodyMedium?.copyWith(
                    color: KineticTokens.zincGray,
                  ),
                ),
                TextButton(
                  onPressed: () => context.read<BillingCubit>().load(),
                  child: Text('billing.retry'.tr()),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'billing.section_heading'.tr(),
              style: textTheme.labelLarge?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: KineticTokens.zincGray,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'billing.subtitle'.tr(),
              style: textTheme.bodySmall?.copyWith(
                color: KineticTokens.zincGray,
              ),
            ),
            if (widget.canWrite) ...[
              const SizedBox(height: 16),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: OutlinedButton.icon(
                  onPressed: state.busy
                      ? null
                      : () => context.read<BillingCubit>().applyFreeze(),
                  icon: const Icon(Icons.ac_unit),
                  label: Text('billing.cta.apply_freeze'.tr()),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: KineticTokens.electricLime,
                    side: const BorderSide(color: KineticTokens.electricLime),
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              Text(
                'billing.read_only_hint'.tr(),
                style: textTheme.bodySmall?.copyWith(
                  color: KineticTokens.zincGray,
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (state.charges.isEmpty)
              Text(
                'billing.empty'.tr(),
                style: textTheme.bodyMedium?.copyWith(
                  color: KineticTokens.zincGray,
                ),
              )
            else
              ...state.charges.map(
                (charge) => _ChargeTile(
                  charge: charge,
                  canWrite: widget.canWrite,
                  busy: state.busy,
                  onMarkPaid: () => context.read<BillingCubit>().markStatus(
                    chargeId: charge.id,
                    status: MembershipChargeStatus.paid,
                  ),
                  onMarkWaived: () => context.read<BillingCubit>().markStatus(
                    chargeId: charge.id,
                    status: MembershipChargeStatus.waived,
                  ),
                  onMarkFailed: () => context.read<BillingCubit>().markStatus(
                    chargeId: charge.id,
                    status: MembershipChargeStatus.failed,
                  ),
                ),
              ),
            if (state.busy)
              const Padding(
                padding: EdgeInsetsDirectional.only(top: 12),
                child: LinearProgressIndicator(
                  color: KineticTokens.electricLime,
                  backgroundColor: KineticTokens.neutralTrack,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ChargeTile extends StatelessWidget {
  const _ChargeTile({
    required this.charge,
    required this.canWrite,
    required this.busy,
    required this.onMarkPaid,
    required this.onMarkWaived,
    required this.onMarkFailed,
  });

  final MembershipCharge charge;
  final bool canWrite;
  final bool busy;
  final VoidCallback onMarkPaid;
  final VoidCallback onMarkWaived;
  final VoidCallback onMarkFailed;

  @override
  Widget build(BuildContext context) {
    final price = (charge.amountCents / 100).toStringAsFixed(2);
    final due = DateFormat.yMMMd().format(charge.dueAt.toLocal());
    final athlete = charge.athleteName ?? charge.athleteId;
    final plan = charge.planName ?? '—';

    return Container(
      margin: const EdgeInsetsDirectional.only(bottom: 12),
      padding: const EdgeInsetsDirectional.all(16),
      decoration: BoxDecoration(
        color: KineticTokens.gunmetalCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: KineticTokens.zincGray.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  athlete,
                  style: const TextStyle(
                    color: KineticTokens.pureWhite,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                charge.status.labelKey.tr(),
                style: TextStyle(
                  color: _statusColor(charge.status),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'billing.charge_meta'.tr(
              namedArgs: {
                'plan': plan,
                'price': price,
                'currency': charge.currency,
                'due': due,
              },
            ),
            style: const TextStyle(color: KineticTokens.zincGray, fontSize: 13),
          ),
          if (canWrite && charge.canMarkPaidOrWaived) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                TextButton(
                  onPressed: busy ? null : onMarkPaid,
                  child: Text('billing.cta.mark_paid'.tr()),
                ),
                TextButton(
                  onPressed: busy ? null : onMarkWaived,
                  child: Text('billing.cta.mark_waived'.tr()),
                ),
                TextButton(
                  onPressed: busy ? null : onMarkFailed,
                  child: Text('billing.cta.mark_failed'.tr()),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _statusColor(MembershipChargeStatus status) {
    switch (status) {
      case MembershipChargeStatus.paid:
        return KineticTokens.electricLime;
      case MembershipChargeStatus.waived:
        return KineticTokens.zincGray;
      case MembershipChargeStatus.failed:
        return Colors.redAccent;
      case MembershipChargeStatus.pending:
        return Colors.amberAccent;
    }
  }
}
