import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/billing_failure.dart';
import '../../domain/entities/membership_charge.dart';
import '../../domain/use_cases/billing_use_cases.dart';

part 'billing_state.dart';

class BillingCubit extends Cubit<BillingState> {
  BillingCubit({
    required ListMembershipChargesUseCase listCharges,
    required UpdateMembershipChargeStatusUseCase updateStatus,
    required ApplyBillingFreezeUseCase applyFreeze,
  }) : _listCharges = listCharges,
       _updateStatus = updateStatus,
       _applyFreeze = applyFreeze,
       super(const BillingState());

  final ListMembershipChargesUseCase _listCharges;
  final UpdateMembershipChargeStatusUseCase _updateStatus;
  final ApplyBillingFreezeUseCase _applyFreeze;

  Future<void> load() async {
    emit(state.copyWith(status: BillingStatus.loading, clearMessage: true));
    try {
      final charges = await _listCharges();
      emit(state.copyWith(status: BillingStatus.ready, charges: charges));
    } on BillingFailure catch (e) {
      emit(
        state.copyWith(status: BillingStatus.failure, messageKey: e.messageKey),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: BillingStatus.failure,
          messageKey: const BillingUnknownFailure().messageKey,
        ),
      );
    }
  }

  Future<void> markStatus({
    required String chargeId,
    required MembershipChargeStatus status,
  }) async {
    emit(state.copyWith(busy: true, clearMessage: true));
    try {
      await _updateStatus(chargeId: chargeId, status: status);
      final charges = await _listCharges();
      final successKey = switch (status) {
        MembershipChargeStatus.paid => 'billing.success.marked_paid',
        MembershipChargeStatus.waived => 'billing.success.marked_waived',
        MembershipChargeStatus.failed => 'billing.success.marked_failed',
        MembershipChargeStatus.pending => 'billing.success.updated',
      };
      emit(
        state.copyWith(busy: false, charges: charges, messageKey: successKey),
      );
    } on BillingFailure catch (e) {
      emit(state.copyWith(busy: false, messageKey: e.messageKey));
    } catch (_) {
      emit(
        state.copyWith(
          busy: false,
          messageKey: const BillingUnknownFailure().messageKey,
        ),
      );
    }
  }

  Future<void> applyFreeze() async {
    emit(state.copyWith(busy: true, clearMessage: true));
    try {
      final paused = await _applyFreeze();
      emit(
        state.copyWith(
          busy: false,
          freezePausedCount: paused,
          messageKey: 'billing.success.freeze_applied',
        ),
      );
    } on BillingFailure catch (e) {
      emit(state.copyWith(busy: false, messageKey: e.messageKey));
    } catch (_) {
      emit(
        state.copyWith(
          busy: false,
          messageKey: const BillingUnknownFailure().messageKey,
        ),
      );
    }
  }
}
