import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/offline_sync_failure.dart';
import '../../domain/use_cases/offline_sync_use_case.dart';
import 'offline_sync_state.dart';

/// Starts bulk attendance upsert when connectivity returns (Phase 1.3).
class OfflineSyncCubit extends Cubit<OfflineSyncState> {
  OfflineSyncCubit({
    required SyncPendingAttendanceUseCase syncPendingAttendance,
    required String tenantId,
    required bool Function() isOnline,
    required Stream<bool> onConnectivityChanged,
  }) : _syncPendingAttendance = syncPendingAttendance,
       _tenantId = tenantId,
       _isOnline = isOnline,
       _onConnectivityChanged = onConnectivityChanged,
       super(const OfflineSyncState.idle());

  final SyncPendingAttendanceUseCase _syncPendingAttendance;
  final String _tenantId;
  final bool Function() _isOnline;
  final Stream<bool> _onConnectivityChanged;

  StreamSubscription<bool>? _connectivitySub;
  bool _started = false;
  bool _syncInFlight = false;

  Future<void> start() async {
    if (_started) return;
    _started = true;

    _connectivitySub = _onConnectivityChanged.listen((online) async {
      if (online) {
        await syncNow();
      }
    });

    if (_isOnline()) {
      await syncNow();
    }
  }

  /// Explicit flush (reconnect or manual retry).
  Future<void> syncNow() async {
    if (_syncInFlight) return;
    _syncInFlight = true;
    emit(state.copyWith(status: OfflineSyncStatus.syncing, clearStatus: true));

    try {
      final result = await _syncPendingAttendance(tenantId: _tenantId);
      if (result.occupancyUpdateDenied) {
        emit(
          state.copyWith(
            status: OfflineSyncStatus.success,
            upsertedCount: result.upsertedCount,
            statusMessageKey: 'connectivity.sync.error.occupancy_rls',
            occupancyDenialDetail: result.occupancyDenialDetail,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: OfflineSyncStatus.success,
          upsertedCount: result.upsertedCount,
          clearStatus: true,
        ),
      );
    } on OfflineSyncFailure catch (failure) {
      emit(
        state.copyWith(
          status: OfflineSyncStatus.failure,
          statusMessageKey: failure.message.split(';').first,
          occupancyDenialDetail: failure.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: OfflineSyncStatus.failure,
          statusMessageKey: 'connectivity.sync.error.unknown',
        ),
      );
    } finally {
      _syncInFlight = false;
    }
  }

  @override
  Future<void> close() async {
    await _connectivitySub?.cancel();
    return super.close();
  }
}
