import '../../../domain/entities/member_roster_entry.dart';

abstract class MemberRosterRemoteDataSource {
  Future<List<MemberRosterEntry>> fetchAthletes();
}
