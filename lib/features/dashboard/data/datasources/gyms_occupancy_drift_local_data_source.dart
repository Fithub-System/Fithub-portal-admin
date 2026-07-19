import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/gym_occupancy.dart';
import 'gyms_occupancy_local_data_source.dart';

class GymsOccupancyDriftLocalDataSource
    implements GymsOccupancyLocalDataSource {
  GymsOccupancyDriftLocalDataSource(this._database);

  final AppDatabase _database;

  @override
  Future<GymOccupancy?> readCached(String tenantId) async {
    final row = await _database.gymForTenant(tenantId);
    if (row == null) return null;
    return GymOccupancy(
      id: row.tenantId,
      name: row.name,
      currentOccupancy: row.currentOccupancy,
      capacityLimit: row.capacityLimit,
    );
  }

  @override
  Future<void> writeCache(GymOccupancy occupancy) {
    return _database.upsertGymCache(
      LocalGymCacheCompanion.insert(
        tenantId: occupancy.id,
        name: occupancy.name,
        currentOccupancy: Value(occupancy.currentOccupancy),
        capacityLimit: occupancy.capacityLimit,
      ),
    );
  }
}
