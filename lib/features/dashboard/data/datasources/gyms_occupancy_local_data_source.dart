import '../../domain/entities/gym_occupancy.dart';

/// Local Drift cache port for gym occupancy (FEAT-04 AC-C2).
abstract class GymsOccupancyLocalDataSource {
  Future<GymOccupancy?> readCached(String tenantId);

  Future<void> writeCache(GymOccupancy occupancy);
}
