abstract class MemberRosterRepository {
  /// Fetches tenant athletes from cloud and upserts into Drift `LocalMembers`.
  Future<int> syncRoster({required String tenantId});

  /// Returns how many members are already cached in Drift for [tenantId].
  Future<int> countCachedMembers({required String tenantId});
}
