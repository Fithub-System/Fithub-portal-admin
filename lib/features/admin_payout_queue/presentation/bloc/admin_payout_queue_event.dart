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

final class AdminPayoutQueueMessageCleared extends AdminPayoutQueueEvent {
  const AdminPayoutQueueMessageCleared();
}
