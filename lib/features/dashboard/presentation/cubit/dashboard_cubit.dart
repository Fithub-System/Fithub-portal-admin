import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../scan/data/repositories/scan_repository.dart';
import '../../data/datasources/gyms_occupancy_local_data_source.dart';
import '../../domain/entities/gym_occupancy.dart';
import '../../domain/repositories/gyms_occupancy_repository.dart';

/// Dashboard occupancy Cubit — no `supabase_flutter` import (FEAT-04 AC-C3).
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({
    required GymsOccupancyLocalDataSource local,
    required GymsOccupancyRepository gymsRepository,
    required String tenantId,
    required bool Function() isOnline,
    required Stream<bool> onConnectivityChanged,
    ScanRepository? scanRepository,
  }) : _local = local,
       _gymsRepository = gymsRepository,
       _tenantId = tenantId,
       _isOnline = isOnline,
       _onConnectivityChanged = onConnectivityChanged,
       _scanRepository = scanRepository,
       super(const DashboardState.initial());

  final GymsOccupancyLocalDataSource _local;
  final GymsOccupancyRepository _gymsRepository;
  final String _tenantId;
  final bool Function() _isOnline;
  final Stream<bool> _onConnectivityChanged;
  final ScanRepository? _scanRepository;

  StreamSubscription<GymOccupancy>? _remoteSub;
  StreamSubscription<bool>? _connectivitySub;
  bool _started = false;

  /// Load Drift cache, then attach realtime when online.
  Future<void> start() async {
    if (_started) return;
    _started = true;

    await loadFromCache();

    _connectivitySub = _onConnectivityChanged.listen((online) async {
      if (online) {
        await _attachRemote();
      } else {
        await _detachRemote();
        await loadFromCache();
      }
    });

    if (_isOnline()) {
      await _attachRemote();
    }
  }

  /// Prefer Drift [GymsOccupancyLocalDataSource] (SafeMode / offline).
  Future<void> loadFromCache() async {
    final gym = await _local.readCached(_tenantId);
    emit(
      state.copyWith(
        currentOccupancy: gym?.currentOccupancy ?? state.currentOccupancy,
        capacityLimit: gym?.capacityLimit ?? state.capacityLimit,
        gymName: gym?.name ?? state.gymName,
        source: OccupancySource.cache,
        clearStatus: true,
      ),
    );
  }

  /// Alias used by older call sites / tests.
  Future<void> load() => loadFromCache();

  Future<void> _attachRemote() async {
    await _detachRemote();

    var oneShotOk = false;
    try {
      final snapshot = await _gymsRepository.fetchOccupancy(_tenantId);
      if (snapshot != null) {
        oneShotOk = true;
        await _persistAndEmit(snapshot, OccupancySource.remote);
      } else {
        emit(state.copyWith(statusMessageKey: 'dashboard.status.no_gym_row'));
      }
    } catch (_) {
      emit(state.copyWith(statusMessageKey: 'dashboard.status.fetch_failed'));
    }

    _remoteSub = _gymsRepository
        .watchOccupancy(_tenantId)
        .listen(
          (occupancy) async {
            try {
              await _persistAndEmit(occupancy, OccupancySource.remote);
            } catch (_) {
              emit(
                state.copyWith(
                  statusMessageKey: 'dashboard.status.fetch_failed',
                ),
              );
            }
          },
          onError: (Object _) {
            // Soft fallback: keep one-shot / Drift; localized recoverable status.
            emit(
              state.copyWith(
                statusMessageKey: oneShotOk
                    ? 'dashboard.status.realtime_degraded'
                    : 'dashboard.status.realtime_failed',
              ),
            );
          },
        );
  }

  Future<void> _detachRemote() async {
    await _remoteSub?.cancel();
    _remoteSub = null;
  }

  Future<void> _persistAndEmit(
    GymOccupancy occupancy,
    OccupancySource source,
  ) async {
    final named = occupancy.name.isEmpty ? state.gymName : occupancy.name;
    await _local.writeCache(
      GymOccupancy(
        id: occupancy.id,
        name: named,
        currentOccupancy: occupancy.currentOccupancy,
        capacityLimit: occupancy.capacityLimit,
      ),
    );

    emit(
      state.copyWith(
        currentOccupancy: occupancy.currentOccupancy,
        capacityLimit: occupancy.capacityLimit,
        gymName: named,
        source: source,
        clearStatus: true,
      ),
    );
  }

  Future<void> simulateOfflineScan(String rawPayload) async {
    final scanRepository = _scanRepository;
    if (scanRepository == null) return;

    final result = await scanRepository.processOfflineScan(
      tenantId: _tenantId,
      rawPayload: rawPayload,
    );

    _emitScanResult(result);
  }

  void reportScanResult(ScanProcessResult result) {
    _emitScanResult(result);
  }

  void _emitScanResult(ScanProcessResult result) {
    if (result.isApproved) {
      emit(
        state.copyWith(
          currentOccupancy: result.occupancy ?? state.currentOccupancy,
          lastScanMessageKey: 'dashboard.scan.approved',
          lastScanMemberName: result.memberName,
          source: OccupancySource.cache,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        lastScanMessageKey: 'dashboard.scan.rejected',
        lastScanRejectReason: result.reason,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _detachRemote();
    await _connectivitySub?.cancel();
    return super.close();
  }
}

enum OccupancySource { initial, cache, remote }

class DashboardState extends Equatable {
  const DashboardState({
    required this.currentOccupancy,
    required this.capacityLimit,
    required this.gymName,
    this.lastScanMessageKey,
    this.lastScanMemberName,
    this.lastScanRejectReason,
    this.source = OccupancySource.initial,
    this.statusMessageKey,
  });

  const DashboardState.initial()
    : currentOccupancy = 0,
      capacityLimit = 0,
      gymName = '',
      lastScanMessageKey = null,
      lastScanMemberName = null,
      lastScanRejectReason = null,
      source = OccupancySource.initial,
      statusMessageKey = null;

  final int currentOccupancy;
  final int capacityLimit;
  final String gymName;
  final String? lastScanMessageKey;
  final String? lastScanMemberName;
  final String? lastScanRejectReason;
  final OccupancySource source;

  /// Localized recoverable status (realtime soft-fallback etc.).
  final String? statusMessageKey;

  /// Legacy accessor for tests / callers that used [errorMessage].
  String? get errorMessage => statusMessageKey;

  /// Legacy accessor for tests that check [lastScanMessage] string.
  String? get lastScanMessage {
    if (lastScanMessageKey == null) return null;
    if (lastScanMessageKey == 'dashboard.scan.approved') {
      return 'Approved: $lastScanMemberName';
    }
    if (lastScanMessageKey == 'dashboard.scan.rejected') {
      return 'Rejected: $lastScanRejectReason';
    }
    return lastScanMessageKey;
  }

  DashboardState copyWith({
    int? currentOccupancy,
    int? capacityLimit,
    String? gymName,
    String? lastScanMessageKey,
    String? lastScanMemberName,
    String? lastScanRejectReason,
    OccupancySource? source,
    String? statusMessageKey,
    bool clearStatus = false,
  }) {
    return DashboardState(
      currentOccupancy: currentOccupancy ?? this.currentOccupancy,
      capacityLimit: capacityLimit ?? this.capacityLimit,
      gymName: gymName ?? this.gymName,
      lastScanMessageKey: lastScanMessageKey ?? this.lastScanMessageKey,
      lastScanMemberName: lastScanMemberName ?? this.lastScanMemberName,
      lastScanRejectReason: lastScanRejectReason ?? this.lastScanRejectReason,
      source: source ?? this.source,
      statusMessageKey: clearStatus
          ? null
          : (statusMessageKey ?? this.statusMessageKey),
    );
  }

  @override
  List<Object?> get props => [
    currentOccupancy,
    capacityLimit,
    gymName,
    lastScanMessageKey,
    lastScanMemberName,
    lastScanRejectReason,
    source,
    statusMessageKey,
  ];
}
