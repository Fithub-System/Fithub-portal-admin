import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/overview_expiring_row.dart';
import '../../domain/entities/overview_home_metrics.dart';
import '../../domain/repositories/overview_home_metrics_repository.dart';

enum OverviewMetricsStatus { initial, loading, ready, failure }

class OverviewMetricsState extends Equatable {
  const OverviewMetricsState({
    this.status = OverviewMetricsStatus.initial,
    this.metrics,
    this.statusMessageKey,
  });

  final OverviewMetricsStatus status;
  final OverviewHomeMetrics? metrics;
  final String? statusMessageKey;

  bool get isLiveBound =>
      status == OverviewMetricsStatus.ready ||
      status == OverviewMetricsStatus.failure;

  /// Honest empty metrics when ready/failure with null payload.
  OverviewHomeMetrics get displayMetrics =>
      metrics ??
      const OverviewHomeMetrics(
        membersCount: 0,
        checkInsToday: 0,
        revenueTodayCents: 0,
        revenueCurrency: OverviewHomeMetrics.defaultCurrency,
        expiringSoon: <OverviewExpiringRow>[],
      );

  OverviewMetricsState copyWith({
    OverviewMetricsStatus? status,
    OverviewHomeMetrics? metrics,
    String? statusMessageKey,
    bool clearStatus = false,
  }) {
    return OverviewMetricsState(
      status: status ?? this.status,
      metrics: metrics ?? this.metrics,
      statusMessageKey: clearStatus
          ? null
          : (statusMessageKey ?? this.statusMessageKey),
    );
  }

  @override
  List<Object?> get props => [status, metrics, statusMessageKey];
}

/// FEAT-60 — loads live Home Overview KPIs for Admin tenant.
class OverviewMetricsCubit extends Cubit<OverviewMetricsState> {
  OverviewMetricsCubit({
    required OverviewHomeMetricsRepository repository,
    required String tenantId,
  }) : _repository = repository,
       _tenantId = tenantId,
       super(const OverviewMetricsState());

  final OverviewHomeMetricsRepository _repository;
  final String _tenantId;
  bool _started = false;

  Future<void> start() async {
    if (_started) return;
    _started = true;
    await refresh();
  }

  Future<void> refresh() async {
    emit(state.copyWith(status: OverviewMetricsStatus.loading));
    try {
      final metrics = await _repository.load(tenantId: _tenantId);
      emit(
        OverviewMetricsState(
          status: OverviewMetricsStatus.ready,
          metrics: metrics,
        ),
      );
    } catch (_) {
      emit(
        OverviewMetricsState(
          status: OverviewMetricsStatus.failure,
          metrics: state.metrics ??
              const OverviewHomeMetrics(
                membersCount: 0,
                checkInsToday: 0,
                revenueTodayCents: 0,
                revenueCurrency: OverviewHomeMetrics.defaultCurrency,
                expiringSoon: <OverviewExpiringRow>[],
              ),
          statusMessageKey: 'dashboard.metrics.load_failed',
        ),
      );
    }
  }
}
