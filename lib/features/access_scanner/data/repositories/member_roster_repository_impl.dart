import '../../domain/entities/member_roster_entry.dart';
import '../../domain/member_roster_failure.dart';
import '../../domain/repositories/member_roster_repository.dart';
import '../data_sources/local/member_roster_local_data_source.dart';
import '../data_sources/remote/member_roster_remote_data_source.dart';

class MemberRosterRepositoryImpl implements MemberRosterRepository {
  MemberRosterRepositoryImpl({
    required MemberRosterRemoteDataSource remote,
    required MemberRosterLocalDataSource local,
  }) : _remote = remote,
       _local = local;

  final MemberRosterRemoteDataSource _remote;
  final MemberRosterLocalDataSource _local;

  @override
  Future<int> syncRoster({required String tenantId}) async {
    List<MemberRosterEntry> members;
    try {
      members = await _remote.fetchAthletes();
    } on MemberRosterFailure {
      rethrow;
    } catch (_) {
      throw const MemberRosterUnknownFailure();
    }

    await _local.upsertMembers(tenantId: tenantId, members: members);
    return members.length;
  }

  @override
  Future<int> countCachedMembers({required String tenantId}) {
    return _local.countCachedMembers(tenantId: tenantId);
  }

  @override
  Future<List<MemberRosterEntry>> listCachedMembers({
    required String tenantId,
  }) {
    return _local.listCachedMembers(tenantId: tenantId);
  }
}
