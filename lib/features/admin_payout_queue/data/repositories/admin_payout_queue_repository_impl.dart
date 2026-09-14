import '../../domain/entities/coach_payout_request.dart';
import '../../domain/repositories/admin_payout_queue_repository.dart';
import '../data_sources/remote/admin_payout_queue_remote_data_source.dart';

class AdminPayoutQueueRepositoryImpl implements AdminPayoutQueueRepository {
  AdminPayoutQueueRepositoryImpl({
    required AdminPayoutQueueRemoteDataSource remote,
  }) : _remote = remote;

  final AdminPayoutQueueRemoteDataSource _remote;

  @override
  Future<List<CoachPayoutRequest>> listRequests({int limit = 100}) {
    return _remote.listRequests(limit: limit);
  }

  @override
  Future<CoachPayoutRequest> fulfill({
    required String requestId,
    required AdminPayoutFulfillAction action,
  }) {
    return _remote.fulfill(requestId: requestId, action: action);
  }

  @override
  Future<CoachPayoutRequest> approve({required String requestId}) {
    return _remote.approve(requestId: requestId);
  }

  @override
  Future<CoachPayoutRequest> beginSettlement({required String requestId}) {
    return _remote.beginSettlement(requestId: requestId);
  }

  @override
  Future<CoachPayoutRequest> applySettlement({
    required String requestId,
    required String settlementTxnId,
    required bool success,
    String? note,
  }) {
    return _remote.applySettlement(
      requestId: requestId,
      settlementTxnId: settlementTxnId,
      success: success,
      note: note,
    );
  }
}
