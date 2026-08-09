import 'package:fithub_portal_admin/core/network/cloud_mutation_guard.dart';

import '../admin_payout_failure.dart';
import '../entities/coach_payout_request.dart';
import '../repositories/admin_payout_queue_repository.dart';

class ListAdminPayoutRequestsUseCase {
  ListAdminPayoutRequestsUseCase(this._repository);

  final AdminPayoutQueueRepository _repository;

  Future<List<CoachPayoutRequest>> call({int limit = 100}) {
    return _repository.listRequests(limit: limit);
  }
}

class FulfillAdminPayoutUseCase {
  FulfillAdminPayoutUseCase(
    this._repository, {
    required CloudMutationGuard cloudGuard,
  }) : _cloudGuard = cloudGuard;

  final AdminPayoutQueueRepository _repository;
  final CloudMutationGuard _cloudGuard;

  Future<CoachPayoutRequest> call({
    required String requestId,
    required AdminPayoutFulfillAction action,
  }) {
    if (!_cloudGuard.isOnline) {
      throw const AdminPayoutOfflineFailure();
    }
    return _repository.fulfill(requestId: requestId, action: action);
  }
}
