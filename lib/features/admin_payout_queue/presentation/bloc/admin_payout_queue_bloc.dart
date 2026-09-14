import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/admin_payout_failure.dart';
import '../../domain/entities/coach_payout_request.dart';
import '../../domain/use_cases/admin_payout_queue_use_cases.dart';
import '../fixtures/admin_payout_stitch_fixtures.dart';

part 'admin_payout_queue_event.dart';
part 'admin_payout_queue_state.dart';

class AdminPayoutQueueBloc
    extends Bloc<AdminPayoutQueueEvent, AdminPayoutQueueState> {
  AdminPayoutQueueBloc({
    required ListAdminPayoutRequestsUseCase listRequests,
    required FulfillAdminPayoutUseCase fulfill,
    required ApproveAdminPayoutUseCase approve,
    required BeginAdminPayoutSettlementUseCase beginSettlement,
    required ApplyAdminPayoutSettlementUseCase applySettlement,
  })  : _listRequests = listRequests,
        _fulfill = fulfill,
        _approve = approve,
        _beginSettlement = beginSettlement,
        _applySettlement = applySettlement,
        super(const AdminPayoutQueueState()) {
    on<AdminPayoutQueueLoadRequested>(_onLoad);
    on<AdminPayoutQueueFilterChanged>(_onFilterChanged);
    on<AdminPayoutQueueFulfillRequested>(_onFulfill);
    on<AdminPayoutQueueApproveRequested>(_onApprove);
    on<AdminPayoutQueueBeginSettlementRequested>(_onBeginSettlement);
    on<AdminPayoutQueueApplySettlementRequested>(_onApplySettlement);
    on<AdminPayoutQueueMessageCleared>(_onClearMessage);
  }

  final ListAdminPayoutRequestsUseCase _listRequests;
  final FulfillAdminPayoutUseCase _fulfill;
  final ApproveAdminPayoutUseCase _approve;
  final BeginAdminPayoutSettlementUseCase _beginSettlement;
  final ApplyAdminPayoutSettlementUseCase _applySettlement;

  Future<void> _onLoad(
    AdminPayoutQueueLoadRequested event,
    Emitter<AdminPayoutQueueState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AdminPayoutQueueStatus.loading,
        clearMessage: true,
      ),
    );
    try {
      final rows = await _listRequests();
      emit(
        state.copyWith(
          status: AdminPayoutQueueStatus.ready,
          requests: rows,
          usingFixtures: false,
        ),
      );
    } on AdminPayoutNotConfiguredFailure catch (e) {
      emit(
        state.copyWith(
          status: AdminPayoutQueueStatus.ready,
          requests: AdminPayoutStitchFixtures.sampleRequests,
          usingFixtures: true,
          messageKey: e.messageKey,
        ),
      );
    } on AdminPayoutFailure catch (e) {
      emit(
        state.copyWith(
          status: AdminPayoutQueueStatus.failure,
          messageKey: e.messageKey,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AdminPayoutQueueStatus.failure,
          messageKey: const AdminPayoutUnknownFailure().messageKey,
        ),
      );
    }
  }

  void _onFilterChanged(
    AdminPayoutQueueFilterChanged event,
    Emitter<AdminPayoutQueueState> emit,
  ) {
    emit(state.copyWith(filter: event.filter));
  }

  Future<void> _onFulfill(
    AdminPayoutQueueFulfillRequested event,
    Emitter<AdminPayoutQueueState> emit,
  ) async {
    final blocked = _guardWrite(event.canWrite, emit);
    if (blocked) return;

    emit(state.copyWith(busyRequestId: event.requestId, clearMessage: true));
    try {
      final updated = await _fulfill(
        requestId: event.requestId,
        action: event.action,
      );
      emit(
        _success(
          updated,
          event.action == AdminPayoutFulfillAction.paid
              ? 'payouts.success.marked_paid'
              : 'payouts.success.rejected',
        ),
      );
    } on AdminPayoutFailure catch (e) {
      emit(state.copyWith(clearBusy: true, messageKey: e.messageKey));
    } catch (_) {
      emit(
        state.copyWith(
          clearBusy: true,
          messageKey: const AdminPayoutUnknownFailure().messageKey,
        ),
      );
    }
  }

  Future<void> _onApprove(
    AdminPayoutQueueApproveRequested event,
    Emitter<AdminPayoutQueueState> emit,
  ) async {
    final blocked = _guardWrite(event.canWrite, emit);
    if (blocked) return;

    emit(state.copyWith(busyRequestId: event.requestId, clearMessage: true));
    try {
      final updated = await _approve(requestId: event.requestId);
      emit(_success(updated, 'payouts.success.approved'));
    } on AdminPayoutFailure catch (e) {
      emit(state.copyWith(clearBusy: true, messageKey: e.messageKey));
    } catch (_) {
      emit(
        state.copyWith(
          clearBusy: true,
          messageKey: const AdminPayoutUnknownFailure().messageKey,
        ),
      );
    }
  }

  Future<void> _onBeginSettlement(
    AdminPayoutQueueBeginSettlementRequested event,
    Emitter<AdminPayoutQueueState> emit,
  ) async {
    final blocked = _guardWrite(event.canWrite, emit);
    if (blocked) return;

    emit(state.copyWith(busyRequestId: event.requestId, clearMessage: true));
    try {
      final updated = await _beginSettlement(requestId: event.requestId);
      emit(_success(updated, 'payouts.success.settling'));
    } on AdminPayoutFailure catch (e) {
      emit(state.copyWith(clearBusy: true, messageKey: e.messageKey));
    } catch (_) {
      emit(
        state.copyWith(
          clearBusy: true,
          messageKey: const AdminPayoutUnknownFailure().messageKey,
        ),
      );
    }
  }

  Future<void> _onApplySettlement(
    AdminPayoutQueueApplySettlementRequested event,
    Emitter<AdminPayoutQueueState> emit,
  ) async {
    final blocked = _guardWrite(event.canWrite, emit);
    if (blocked) return;

    emit(state.copyWith(busyRequestId: event.requestId, clearMessage: true));
    try {
      final updated = await _applySettlement(
        requestId: event.requestId,
        settlementTxnId: event.settlementTxnId,
        success: event.success,
        note: event.note,
      );
      emit(
        _success(
          updated,
          event.success
              ? 'payouts.success.settled'
              : 'payouts.success.failed',
        ),
      );
    } on AdminPayoutFailure catch (e) {
      emit(state.copyWith(clearBusy: true, messageKey: e.messageKey));
    } catch (_) {
      emit(
        state.copyWith(
          clearBusy: true,
          messageKey: const AdminPayoutUnknownFailure().messageKey,
        ),
      );
    }
  }

  void _onClearMessage(
    AdminPayoutQueueMessageCleared event,
    Emitter<AdminPayoutQueueState> emit,
  ) {
    emit(state.copyWith(clearMessage: true));
  }

  bool _guardWrite(bool canWrite, Emitter<AdminPayoutQueueState> emit) {
    if (!canWrite) {
      emit(
        state.copyWith(
          messageKey: const AdminPayoutForbiddenFailure().messageKey,
        ),
      );
      return true;
    }
    if (state.usingFixtures) {
      emit(
        state.copyWith(
          messageKey: 'payouts.error.not_configured',
        ),
      );
      return true;
    }
    return false;
  }

  AdminPayoutQueueState _success(CoachPayoutRequest updated, String key) {
    final next = state.requests
        .map((r) => r.id == updated.id ? updated : r)
        .toList(growable: false);
    return state.copyWith(
      requests: next,
      clearBusy: true,
      messageKey: key,
    );
  }
}
