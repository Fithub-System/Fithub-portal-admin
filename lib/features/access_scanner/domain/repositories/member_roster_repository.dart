import '../entities/member_roster_entry.dart';

abstract class MemberRosterRepository {
  /// Fetches tenant athletes from cloud and upserts into Drift `LocalMembers`.
  Future<int> syncRoster({required String tenantId});

  /// Returns how many members are already cached in Drift for [tenantId].
  Future<int> countCachedMembers({required String tenantId});

  /// Returns cached roster rows for [tenantId] (Drift `LocalMembers`).
  Future<List<MemberRosterEntry>> listCachedMembers({required String tenantId});
}
