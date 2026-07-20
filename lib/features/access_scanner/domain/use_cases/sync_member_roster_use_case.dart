import '../repositories/member_roster_repository.dart';

class SyncMemberRosterUseCase {
  const SyncMemberRosterUseCase(this._repository);

  final MemberRosterRepository _repository;

  Future<int> call({required String tenantId}) {
    return _repository.syncRoster(tenantId: tenantId);
  }
}
