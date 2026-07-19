import 'package:drift/drift.dart';

/// Bit-for-bit local mirror of `public.gyms` occupancy fields.
@DataClassName('LocalGymCacheEntry')
class LocalGymCache extends Table {
  TextColumn get tenantId => text()();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  IntColumn get currentOccupancy => integer().withDefault(const Constant(0))();
  IntColumn get capacityLimit => integer()();

  @override
  Set<Column<Object>> get primaryKey => {tenantId};
}
