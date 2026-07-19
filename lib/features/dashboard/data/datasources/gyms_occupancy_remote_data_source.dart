import '../../domain/entities/gym_occupancy.dart';

/// Remote I/O port for gym occupancy (FEAT-04 AC-C2).
abstract class GymsOccupancyRemoteDataSource {
  Future<GymOccupancy?> fetchOccupancy(String tenantId);

  /// Live updates when the backend supports Realtime / WS / SSE.
  Stream<GymOccupancy> watchOccupancy(String tenantId);
}
