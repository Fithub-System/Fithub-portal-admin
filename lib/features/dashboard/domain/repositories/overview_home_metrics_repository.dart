import '../entities/overview_home_metrics.dart';

/// Loads live Home Overview KPIs (FEAT-60). User-JWT only — no service_role.
abstract class OverviewHomeMetricsRepository {
  Future<OverviewHomeMetrics> load({required String tenantId});
}
