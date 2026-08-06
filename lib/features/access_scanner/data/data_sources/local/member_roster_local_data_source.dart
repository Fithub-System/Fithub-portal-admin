import 'package:drift/drift.dart';

import '../../../../../core/database/app_database.dart';
import '../../../domain/entities/member_roster_entry.dart';

abstract class MemberRosterLocalDataSource {
  Future<void> upsertMembers({
    required String tenantId,
    required List<MemberRosterEntry> members,
  });

  Future<int> countCachedMembers({required String tenantId});

  Future<List<MemberRosterEntry>> listCachedMembers({required String tenantId});
}

class MemberRosterDriftLocalDataSource implements MemberRosterLocalDataSource {
  MemberRosterDriftLocalDataSource(this._database);

  final AppDatabase _database;

  @override
  Future<void> upsertMembers({
    required String tenantId,
    required List<MemberRosterEntry> members,
  }) {
    final companions = members
        .map(
          (member) => LocalMembersCompanion.insert(
            id: member.id,
            tenantId: tenantId,
            fullName: member.fullName,
            avatarUrl: Value(member.avatarUrl),
            powerScore: Value(member.powerScore),
            cryptoSalt: member.cryptoSalt,
            createdAt: member.createdAt,
            membershipStatus: Value(member.membershipStatus),
            membershipPlanName: Value(member.membershipPlanName),
            membershipEndsAt: Value(member.membershipEndsAt),
          ),
        )
        .toList(growable: false);

    return _database.upsertMembers(companions);
  }

  @override
  Future<int> countCachedMembers({required String tenantId}) {
    return _database.countMembersForTenant(tenantId);
  }

  @override
  Future<List<MemberRosterEntry>> listCachedMembers({
    required String tenantId,
  }) async {
    final rows = await _database.listMembersForTenant(tenantId);
    return rows
        .map(
          (row) => MemberRosterEntry(
            id: row.id,
            fullName: row.fullName,
            avatarUrl: row.avatarUrl,
            powerScore: row.powerScore,
            cryptoSalt: row.cryptoSalt,
            createdAt: row.createdAt,
            membershipStatus: row.membershipStatus,
            membershipPlanName: row.membershipPlanName,
            membershipEndsAt: row.membershipEndsAt,
          ),
        )
        .toList(growable: false);
  }
}
