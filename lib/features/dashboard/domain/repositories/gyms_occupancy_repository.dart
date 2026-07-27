import '../entities/gym_occupancy.dart';

/// Reads live occupancy for the authenticated employee's tenant gym.
abstract class GymsOccupancyRepository {
  /// One-shot SELECT of `current_occupancy` / `capacity_limit` / `name`.
  Future<GymOccupancy?> fetchOccupancy(String tenantId);

  /// Realtime stream on `public.gyms` filtered by tenant `id`.
  Stream<GymOccupancy> watchOccupancy(String tenantId);
}
