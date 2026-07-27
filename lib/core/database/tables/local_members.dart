import 'package:drift/drift.dart';

/// Bit-for-bit local mirror of `public.athletes` plus tenant scope.
@DataClassName('LocalMember')
class LocalMembers extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get fullName => text().withLength(min: 1, max: 255)();
  TextColumn get avatarUrl => text().nullable()();
  IntColumn get powerScore => integer().withDefault(const Constant(100))();
  TextColumn get cryptoSalt => text().withLength(min: 1, max: 255)();
  DateTimeColumn get createdAt => dateTime()();
  /// Cached from `athlete_memberships.status` (FEAT-07 roster sync).
  TextColumn get membershipStatus => text().nullable()();
  TextColumn get membershipPlanName => text().nullable()();
  DateTimeColumn get membershipEndsAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
