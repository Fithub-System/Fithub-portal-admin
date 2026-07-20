import '../entities/member_roster_entry.dart';

abstract class MemberRosterRepository {
  /// Fetches tenant athletes from cloud and upserts into Drift `LocalMembers`.
  Future<int> syncRoster({required String tenantId});
}
