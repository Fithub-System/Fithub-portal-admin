import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../scan/data/repositories/scan_repository.dart';
import '../../domain/member_roster_failure.dart';
import '../../domain/repositories/member_roster_repository.dart';
import '../../domain/use_cases/process_qr_scan_use_case.dart';
import '../../domain/use_cases/sync_member_roster_use_case.dart';
import 'access_scanner_state.dart';

class AccessScannerCubit extends Cubit<AccessScannerState> {
  AccessScannerCubit({
    required ProcessQrScanUseCase processQrScan,
    required SyncMemberRosterUseCase syncMemberRoster,
    required MemberRosterRepository memberRosterRepository,
    required String tenantId,
    required bool Function() isOnline,
    void Function(ScanProcessResult result)? onScanProcessed,
  }) : _processQrScan = processQrScan,
       _syncMemberRoster = syncMemberRoster,
       _memberRosterRepository = memberRosterRepository,
       _tenantId = tenantId,
       _isOnline = isOnline,
       _onScanProcessed = onScanProcessed,
       super(const AccessScannerState());

  final ProcessQrScanUseCase _processQrScan;
  final SyncMemberRosterUseCase _syncMemberRoster;
  final MemberRosterRepository _memberRosterRepository;
  final String _tenantId;
  final bool Function() _isOnline;
  final void Function(ScanProcessResult result)? _onScanProcessed;

  String? _lastPayload;
  DateTime? _lastScanAt;
  bool _syncInFlight = false;

  /// Shell / screen entry: show cached count, then sync when online.
  Future<void> start() => onScannerOpened();

  /// Re-run when the Scan tab opens so roster refreshes after Backend seed.
  Future<void> onScannerOpened() async {
    await refreshLocalCount();
    if (_isOnline()) {
      await syncRoster();
    }
  }

  Future<void> refreshLocalCount() async {
    try {
      final count = await _memberRosterRepository.countCachedMembers(
        tenantId: _tenantId,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          rosterCount: count,
          rosterStatus: count > 0
              ? AccessScannerRosterStatus.synced
              : state.rosterStatus == AccessScannerRosterStatus.syncing
              ? AccessScannerRosterStatus.syncing
              : AccessScannerRosterStatus.idle,
        ),
      );
    } catch (_) {
      // Local count is best-effort; sync path surfaces failures.
    }
  }

  void markCameraReady() {
    if (state.cameraReady || isClosed) return;
    emit(state.copyWith(cameraReady: true));
  }

  Future<void> syncRoster() async {
    if (_syncInFlight || isClosed) return;
    _syncInFlight = true;

    emit(
      state.copyWith(
        rosterStatus: AccessScannerRosterStatus.syncing,
        clearRosterError: true,
      ),
    );

    try {
      final count = await _syncMemberRoster(tenantId: _tenantId);
      if (isClosed) return;

      if (count == 0) {
        emit(
          state.copyWith(
            rosterStatus: AccessScannerRosterStatus.failed,
            rosterCount: 0,
            rosterErrorKey: 'access_scanner.roster.error.empty',
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          rosterStatus: AccessScannerRosterStatus.synced,
          rosterCount: count,
        ),
      );
    } on MemberRosterFailure catch (failure) {
      if (isClosed) return;
      final localCount = await _safeLocalCount();
      emit(
        state.copyWith(
          rosterStatus: AccessScannerRosterStatus.failed,
          rosterCount: localCount,
          rosterErrorKey: failure.messageKey,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      final localCount = await _safeLocalCount();
      emit(
        state.copyWith(
          rosterStatus: AccessScannerRosterStatus.failed,
          rosterCount: localCount,
          rosterErrorKey: 'access_scanner.roster.error.unknown',
        ),
      );
    } finally {
      _syncInFlight = false;
    }
  }

  Future<int?> _safeLocalCount() async {
    try {
      return await _memberRosterRepository.countCachedMembers(
        tenantId: _tenantId,
      );
    } catch (_) {
      return state.rosterCount;
    }
  }

  Future<void> onQrDetected(String rawPayload) async {
    final trimmed = rawPayload.trim();
    if (trimmed.isEmpty || state.isProcessing || isClosed) return;

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

    if (isClosed) return;

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
    if (isClosed) return;
    emit(state.copyWith(clearSuccess: true));
  }

  void dismissError() {
    if (isClosed) return;
    emit(state.copyWith(clearError: true));
  }
}
