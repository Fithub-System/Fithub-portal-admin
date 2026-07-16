import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/database/app_database.dart';
import '../../../scan/data/repositories/scan_repository.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({
    required AppDatabase database,
    required ScanRepository scanRepository,
    required String tenantId,
  })  : _database = database,
        _scanRepository = scanRepository,
        _tenantId = tenantId,
        super(const DashboardState.initial());

  final AppDatabase _database;
  final ScanRepository _scanRepository;
  final String _tenantId;

  Future<void> load() async {
    final gym = await _database.gymForTenant(_tenantId);
    emit(
      DashboardState(
        currentOccupancy: gym?.currentOccupancy ?? 0,
        capacityLimit: gym?.capacityLimit ?? 0,
        gymName: gym?.name ?? 'Pulse Gym',
        lastScanMessage: state.lastScanMessage,
      ),
    );
  }

  Future<void> simulateOfflineScan(String rawPayload) async {
    final result = await _scanRepository.processOfflineScan(
      tenantId: _tenantId,
      rawPayload: rawPayload,
    );

    if (result.isApproved) {
      emit(
        state.copyWith(
          currentOccupancy: result.occupancy ?? state.currentOccupancy,
          lastScanMessage: 'Approved: ${result.memberName}',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        lastScanMessage: 'Rejected: ${result.reason}',
      ),
    );
  }
}

class DashboardState extends Equatable {
  const DashboardState({
    required this.currentOccupancy,
    required this.capacityLimit,
    required this.gymName,
    this.lastScanMessage,
  });

  const DashboardState.initial()
      : currentOccupancy = 0,
        capacityLimit = 0,
        gymName = 'Pulse Gym',
        lastScanMessage = null;

  final int currentOccupancy;
  final int capacityLimit;
  final String gymName;
  final String? lastScanMessage;

  DashboardState copyWith({
    int? currentOccupancy,
    int? capacityLimit,
    String? gymName,
    String? lastScanMessage,
  }) {
    return DashboardState(
      currentOccupancy: currentOccupancy ?? this.currentOccupancy,
      capacityLimit: capacityLimit ?? this.capacityLimit,
      gymName: gymName ?? this.gymName,
      lastScanMessage: lastScanMessage ?? this.lastScanMessage,
    );
  }

  @override
  List<Object?> get props => [
        currentOccupancy,
        capacityLimit,
        gymName,
        lastScanMessage,
      ];
}
