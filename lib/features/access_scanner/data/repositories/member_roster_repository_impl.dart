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
  final Map<String, List<MemberRosterEntry>> _liveByTenant = {};

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

    _liveByTenant[tenantId] = members;
    try {
      await _local.upsertMembers(tenantId: tenantId, members: members);
    } catch (_) {
      // Drift CHECK / wasm cache must not hide a successful cloud 200.
    }
    return members.length;
  }

  @override
  Future<int> countCachedMembers({required String tenantId}) async {
    try {
      final cached = await _local.countCachedMembers(tenantId: tenantId);
      if (cached > 0) return cached;
    } catch (_) {}
    return _liveByTenant[tenantId]?.length ?? 0;
  }

  @override
  Future<List<MemberRosterEntry>> listCachedMembers({
    required String tenantId,
  }) async {
    try {
      final cached = await _local.listCachedMembers(tenantId: tenantId);
      if (cached.isNotEmpty) return cached;
    } catch (_) {}
    return _liveByTenant[tenantId] ?? const [];
  }
}
