import 'dart:async';

import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/database/app_database.dart';
import '../../../scan/data/repositories/scan_repository.dart';
import '../../domain/entities/gym_occupancy.dart';
import '../../domain/repositories/gyms_occupancy_repository.dart';

/// Dashboard occupancy: Drift cache offline; Supabase realtime when online.
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({
    required AppDatabase this._database,
    required GymsOccupancyRepository this._gymsRepository,
    required String this._tenantId,
    required bool Function() this._isOnline,
    required Stream<bool> this._onConnectivityChanged,
    ScanRepository? this._scanRepository,
  }) : super(const DashboardState.initial());

  final AppDatabase _database;
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

  /// Prefer Drift [LocalGymCache] (SafeMode / offline carry-forward).
  Future<void> loadFromCache() async {
    final gym = await _database.gymForTenant(_tenantId);
    emit(
      state.copyWith(
        currentOccupancy: gym?.currentOccupancy ?? state.currentOccupancy,
        capacityLimit: gym?.capacityLimit ?? state.capacityLimit,
        gymName: gym?.name ?? state.gymName,
        source: OccupancySource.cache,
        clearError: true,
      ),
    );
  }

  /// Alias used by older call sites / tests.
  Future<void> load() => loadFromCache();

  Future<void> _attachRemote() async {
    await _detachRemote();

    try {
      final snapshot = await _gymsRepository.fetchOccupancy(_tenantId);
      if (snapshot != null) {
        await _persistAndEmit(snapshot, OccupancySource.remote);
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }

    _remoteSub = _gymsRepository
        .watchOccupancy(_tenantId)
        .listen(
          (occupancy) async {
            await _persistAndEmit(occupancy, OccupancySource.remote);
          },
          onError: (Object error) {
            emit(state.copyWith(errorMessage: error.toString()));
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
    await _database.upsertGymCache(
      LocalGymCacheCompanion.insert(
        tenantId: occupancy.id,
        name: occupancy.name.isEmpty ? state.gymName : occupancy.name,
        currentOccupancy: Value(occupancy.currentOccupancy),
        capacityLimit: occupancy.capacityLimit,
      ),
    );

    emit(
      state.copyWith(
        currentOccupancy: occupancy.currentOccupancy,
        capacityLimit: occupancy.capacityLimit,
        gymName: occupancy.name.isEmpty ? state.gymName : occupancy.name,
        source: source,
        clearError: true,
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
    this.errorMessage,
  });

  const DashboardState.initial()
    : currentOccupancy = 0,
      capacityLimit = 0,
      gymName = '',
      lastScanMessageKey = null,
      lastScanMemberName = null,
      lastScanRejectReason = null,
      source = OccupancySource.initial,
      errorMessage = null;

  final int currentOccupancy;
  final int capacityLimit;
  final String gymName;
  final String? lastScanMessageKey;
  final String? lastScanMemberName;
  final String? lastScanRejectReason;
  final OccupancySource source;
  final String? errorMessage;

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
    String? errorMessage,
    bool clearError = false,
  }) {
    return DashboardState(
      currentOccupancy: currentOccupancy ?? this.currentOccupancy,
      capacityLimit: capacityLimit ?? this.capacityLimit,
      gymName: gymName ?? this.gymName,
      lastScanMessageKey: lastScanMessageKey ?? this.lastScanMessageKey,
      lastScanMemberName: lastScanMemberName ?? this.lastScanMemberName,
      lastScanRejectReason: lastScanRejectReason ?? this.lastScanRejectReason,
      source: source ?? this.source,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
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
    errorMessage,
  ];
}
