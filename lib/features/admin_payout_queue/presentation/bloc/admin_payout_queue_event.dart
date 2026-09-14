part of 'admin_payout_queue_bloc.dart';

sealed class AdminPayoutQueueEvent extends Equatable {
  const AdminPayoutQueueEvent();

  @override
  List<Object?> get props => const [];
}

final class AdminPayoutQueueLoadRequested extends AdminPayoutQueueEvent {
  const AdminPayoutQueueLoadRequested();
}

final class AdminPayoutQueueFilterChanged extends AdminPayoutQueueEvent {
  const AdminPayoutQueueFilterChanged(this.filter);

  final AdminPayoutFilter filter;

  @override
  List<Object?> get props => [filter];
}

final class AdminPayoutQueueFulfillRequested extends AdminPayoutQueueEvent {
  const AdminPayoutQueueFulfillRequested({
    required this.requestId,
    required this.action,
    required this.canWrite,
  });

  final String requestId;
  final AdminPayoutFulfillAction action;
  final bool canWrite;

  @override
  List<Object?> get props => [requestId, action, canWrite];
}

final class AdminPayoutQueueApproveRequested extends AdminPayoutQueueEvent {
  const AdminPayoutQueueApproveRequested({
    required this.requestId,
    required this.canWrite,
  });

  final String requestId;
  final bool canWrite;

  @override
  List<Object?> get props => [requestId, canWrite];
}

final class AdminPayoutQueueBeginSettlementRequested
    extends AdminPayoutQueueEvent {
  const AdminPayoutQueueBeginSettlementRequested({
    required this.requestId,
    required this.canWrite,
  });

  final String requestId;
  final bool canWrite;

  @override
  List<Object?> get props => [requestId, canWrite];
}

final class AdminPayoutQueueApplySettlementRequested
    extends AdminPayoutQueueEvent {
  const AdminPayoutQueueApplySettlementRequested({
    required this.requestId,
    required this.settlementTxnId,
    required this.success,
    required this.canWrite,
    this.note,
  });

  final String requestId;
  final String settlementTxnId;
  final bool success;
  final bool canWrite;
  final String? note;

  @override
  List<Object?> get props =>
      [requestId, settlementTxnId, success, canWrite, note];
}

final class AdminPayoutQueueMessageCleared extends AdminPayoutQueueEvent {
  const AdminPayoutQueueMessageCleared();
}
