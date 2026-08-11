part of 'admin_payout_queue_bloc.dart';

enum AdminPayoutQueueStatus { initial, loading, ready, failure }

enum AdminPayoutFilter { all, pending, paid, rejected }

final class AdminPayoutQueueState extends Equatable {
  const AdminPayoutQueueState({
    this.status = AdminPayoutQueueStatus.initial,
    this.requests = const [],
    this.filter = AdminPayoutFilter.pending,
    this.busyRequestId,
    this.messageKey,
    this.usingFixtures = false,
  });

  final AdminPayoutQueueStatus status;
  final List<CoachPayoutRequest> requests;
  final AdminPayoutFilter filter;
  final String? busyRequestId;
  final String? messageKey;
  final bool usingFixtures;

  List<CoachPayoutRequest> get filteredRequests {
    switch (filter) {
      case AdminPayoutFilter.all:
        return requests;
      case AdminPayoutFilter.pending:
        return requests
            .where((r) => r.status == CoachPayoutRequestStatus.pending)
            .toList(growable: false);
      case AdminPayoutFilter.paid:
        return requests
            .where((r) => r.status == CoachPayoutRequestStatus.paid)
            .toList(growable: false);
      case AdminPayoutFilter.rejected:
        return requests
            .where((r) => r.status == CoachPayoutRequestStatus.rejected)
            .toList(growable: false);
    }
  }

  int get pendingCount => requests
      .where((r) => r.status == CoachPayoutRequestStatus.pending)
      .length;

  int get paidTodayCount {
    final now = DateTime.now().toUtc();
    return requests.where((r) {
      if (r.status != CoachPayoutRequestStatus.paid) return false;
      final at = r.updatedAt ?? r.createdAt;
      return _isSameUtcDay(at, now);
    }).length;
  }

  int get rejectedTodayCount {
    final now = DateTime.now().toUtc();
    return requests.where((r) {
      if (r.status != CoachPayoutRequestStatus.rejected) return false;
      final at = r.updatedAt ?? r.createdAt;
      return _isSameUtcDay(at, now);
    }).length;
  }

  static bool _isSameUtcDay(DateTime a, DateTime b) =>
      a.toUtc().year == b.toUtc().year &&
      a.toUtc().month == b.toUtc().month &&
      a.toUtc().day == b.toUtc().day;

  AdminPayoutQueueState copyWith({
    AdminPayoutQueueStatus? status,
    List<CoachPayoutRequest>? requests,
    AdminPayoutFilter? filter,
    String? busyRequestId,
    bool clearBusy = false,
    String? messageKey,
    bool clearMessage = false,
    bool? usingFixtures,
  }) {
    return AdminPayoutQueueState(
      status: status ?? this.status,
      requests: requests ?? this.requests,
      filter: filter ?? this.filter,
      busyRequestId: clearBusy ? null : (busyRequestId ?? this.busyRequestId),
      messageKey: clearMessage ? null : (messageKey ?? this.messageKey),
      usingFixtures: usingFixtures ?? this.usingFixtures,
    );
  }

  @override
  List<Object?> get props => [
        status,
        requests,
        filter,
        busyRequestId,
        messageKey,
        usingFixtures,
      ];
}
