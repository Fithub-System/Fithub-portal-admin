import '../../../access_scanner/domain/entities/member_roster_entry.dart';
import '../../../access_scanner/domain/repositories/member_roster_repository.dart';

/// Reads Drift-cached roster for the active tenant (FEAT-07-R roster tab).
class ListCachedMemberRosterUseCase {
  const ListCachedMemberRosterUseCase(this._repository);

  final MemberRosterRepository _repository;

  Future<List<MemberRosterEntry>> call({required String tenantId}) {
    return _repository.listCachedMembers(tenantId: tenantId);
  }
}
