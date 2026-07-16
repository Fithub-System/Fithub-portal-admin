import 'package:drift/drift.dart';

/// Bit-for-bit local mirror of `public.attendance_logs` for offline sync.
@DataClassName('LocalAttendanceQueueItem')
class LocalAttendanceQueue extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get athleteId => text()();
  DateTimeColumn get checkedInAt => dateTime()();
  BoolColumn get isSynced =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
