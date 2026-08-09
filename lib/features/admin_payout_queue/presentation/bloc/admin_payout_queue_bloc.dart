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
  })  : _listRequests = listRequests,
        _fulfill = fulfill,
        super(const AdminPayoutQueueState()) {
    on<AdminPayoutQueueLoadRequested>(_onLoad);
    on<AdminPayoutQueueFilterChanged>(_onFilterChanged);
    on<AdminPayoutQueueFulfillRequested>(_onFulfill);
    on<AdminPayoutQueueMessageCleared>(_onClearMessage);
  }

  final ListAdminPayoutRequestsUseCase _listRequests;
  final FulfillAdminPayoutUseCase _fulfill;

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
    if (!event.canWrite) {
      emit(
        state.copyWith(
          messageKey: const AdminPayoutForbiddenFailure().messageKey,
        ),
      );
      return;
    }
    if (state.usingFixtures) {
      emit(
        state.copyWith(
          messageKey: 'payouts.error.not_configured',
        ),
      );
      return;
    }

    emit(state.copyWith(busyRequestId: event.requestId, clearMessage: true));
    try {
      final updated = await _fulfill(
        requestId: event.requestId,
        action: event.action,
      );
      final next = state.requests
          .map((r) => r.id == updated.id ? updated : r)
          .toList(growable: false);
      emit(
        state.copyWith(
          requests: next,
          clearBusy: true,
          messageKey: event.action == AdminPayoutFulfillAction.paid
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

  void _onClearMessage(
    AdminPayoutQueueMessageCleared event,
    Emitter<AdminPayoutQueueState> emit,
  ) {
    emit(state.copyWith(clearMessage: true));
  }
}
