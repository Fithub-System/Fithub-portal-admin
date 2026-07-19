import '../../../../core/network/api_provider.dart';
import '../../../../core/network/app_endpoints.dart';
import '../../domain/entities/gym_occupancy.dart';
import 'gyms_occupancy_remote_data_source.dart';

/// HTTP adapter via starter-kit [ApiProvider] (OCCUPANCY_BACKEND=http).
///
/// Uses portable `GET /v1/gyms/{id}/occupancy`. Stream contract is documented
/// on [AppEndpoints.gymOccupancyStream]; until a traditional Backend ships WS
/// / SSE, [watchOccupancy] is empty so the Cubit keeps one-shot + Drift.
class GymsOccupancyHttpRemoteDataSource
    implements GymsOccupancyRemoteDataSource {
  GymsOccupancyHttpRemoteDataSource(this._api);

  final ApiProvider _api;

  @override
  Future<GymOccupancy?> fetchOccupancy(String tenantId) async {
    final data = await _api.requestAPI(
      url: AppEndpoints.gymOccupancy(tenantId),
      type: RequestType.get,
    );
    if (data == null) return null;
    if (data is! Map) return null;
    return _fromJson(Map<String, dynamic>.from(data));
  }

  @override
  Stream<GymOccupancy> watchOccupancy(String tenantId) {
    // Contract: AppEndpoints.gymOccupancyStream — wire when Nest/WS exists.
    return const Stream<GymOccupancy>.empty();
  }

  GymOccupancy _fromJson(Map<String, dynamic> json) {
    return GymOccupancy(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      currentOccupancy: _asInt(json['current_occupancy']),
      capacityLimit: _asInt(json['capacity_limit']),
    );
  }

  int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }
}
