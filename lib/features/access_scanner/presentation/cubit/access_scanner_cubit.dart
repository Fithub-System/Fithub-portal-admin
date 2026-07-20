import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../scan/data/repositories/scan_repository.dart';
import '../../domain/member_roster_failure.dart';
import '../../domain/use_cases/process_qr_scan_use_case.dart';
import '../../domain/use_cases/sync_member_roster_use_case.dart';
import 'access_scanner_state.dart';

class AccessScannerCubit extends Cubit<AccessScannerState> {
  AccessScannerCubit({
    required ProcessQrScanUseCase processQrScan,
    required SyncMemberRosterUseCase syncMemberRoster,
    required String tenantId,
    required bool Function() isOnline,
    void Function(ScanProcessResult result)? onScanProcessed,
  }) : _processQrScan = processQrScan,
       _syncMemberRoster = syncMemberRoster,
       _tenantId = tenantId,
       _isOnline = isOnline,
       _onScanProcessed = onScanProcessed,
       super(const AccessScannerState());

  final ProcessQrScanUseCase _processQrScan;
  final SyncMemberRosterUseCase _syncMemberRoster;
  final String _tenantId;
  final bool Function() _isOnline;
  final void Function(ScanProcessResult result)? _onScanProcessed;

  String? _lastPayload;
  DateTime? _lastScanAt;

  Future<void> start() async {
    if (_isOnline()) {
      await syncRoster();
    }
  }

  void markCameraReady() {
    if (state.cameraReady) return;
    emit(state.copyWith(cameraReady: true));
  }

  Future<void> syncRoster() async {
    emit(
      state.copyWith(
        rosterStatus: AccessScannerRosterStatus.syncing,
        clearRosterError: true,
      ),
    );

    try {
      final count = await _syncMemberRoster(tenantId: _tenantId);
      emit(
        state.copyWith(
          rosterStatus: AccessScannerRosterStatus.synced,
          rosterCount: count,
        ),
      );
    } on MemberRosterFailure catch (failure) {
      emit(
        state.copyWith(
          rosterStatus: AccessScannerRosterStatus.failed,
          rosterErrorKey: failure.messageKey,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          rosterStatus: AccessScannerRosterStatus.failed,
          rosterErrorKey: 'access_scanner.roster.error.unknown',
        ),
      );
    }
  }

  Future<void> onQrDetected(String rawPayload) async {
    final trimmed = rawPayload.trim();
    if (trimmed.isEmpty || state.isProcessing) return;

    final now = DateTime.now();
    if (_lastPayload == trimmed &&
        _lastScanAt != null &&
        now.difference(_lastScanAt!) < const Duration(seconds: 3)) {
      return;
    }

    _lastPayload = trimmed;
    _lastScanAt = now;

    emit(state.copyWith(isProcessing: true, clearSuccess: true, clearError: true));

    final result = await _processQrScan(
      tenantId: _tenantId,
      rawPayload: trimmed,
    );

    _onScanProcessed?.call(result);

    if (result.isApproved) {
      emit(
        state.copyWith(
          isProcessing: false,
          success: ScanSuccessNotification(
            memberName: result.memberName ?? '',
            avatarUrl: result.avatarUrl,
            occupancy: result.occupancy ?? 0,
          ),
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isProcessing: false,
        errorKey: 'access_scanner.scan.rejected',
        rejectReason: result.reason,
      ),
    );
  }

  Future<void> processManualPayload(String rawPayload) {
    return onQrDetected(rawPayload);
  }

  void dismissSuccess() {
    emit(state.copyWith(clearSuccess: true));
  }

  void dismissError() {
    emit(state.copyWith(clearError: true));
  }
}
