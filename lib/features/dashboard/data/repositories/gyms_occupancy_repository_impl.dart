import '../../domain/entities/gym_occupancy.dart';
import '../../domain/repositories/gyms_occupancy_repository.dart';
import '../datasources/gyms_occupancy_remote_data_source.dart';

/// Occupancy repository — delegates to remote port only (FEAT-04).
///
/// Presentation / Cubit never sees Supabase or Dio; local Drift is a separate
/// port used by the Cubit for SafeMode cache.
class GymsOccupancyRepositoryImpl implements GymsOccupancyRepository {
  GymsOccupancyRepositoryImpl({required GymsOccupancyRemoteDataSource remote})
    : _remote = remote;

  final GymsOccupancyRemoteDataSource _remote;

  @override
  Future<GymOccupancy?> fetchOccupancy(String tenantId) =>
      _remote.fetchOccupancy(tenantId);

  @override
  Stream<GymOccupancy> watchOccupancy(String tenantId) =>
      _remote.watchOccupancy(tenantId);
}
