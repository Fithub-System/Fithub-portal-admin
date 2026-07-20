import 'package:drift/drift.dart';

import '../../../../../core/database/app_database.dart';
import '../../../domain/entities/member_roster_entry.dart';

abstract class MemberRosterLocalDataSource {
  Future<void> upsertMembers({
    required String tenantId,
    required List<MemberRosterEntry> members,
  });
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
          ),
        )
        .toList(growable: false);

    return _database.upsertMembers(companions);
  }
}
