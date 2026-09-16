import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../access_scanner/domain/entities/member_roster_entry.dart';
import '../../../access_scanner/domain/member_roster_failure.dart';
import '../../../access_scanner/domain/use_cases/sync_member_roster_use_case.dart';
import '../../domain/use_cases/list_cached_member_roster_use_case.dart';

part 'member_roster_state.dart';

class MemberRosterCubit extends Cubit<MemberRosterState> {
  MemberRosterCubit({
    required ListCachedMemberRosterUseCase listCachedRoster,
    required String tenantId,
    SyncMemberRosterUseCase? syncRoster,
    bool Function()? isOnline,
  }) : _listCachedRoster = listCachedRoster,
       _syncRoster = syncRoster,
       _tenantId = tenantId,
       _isOnline = isOnline ?? (() => true),
       super(const MemberRosterState());

  final ListCachedMemberRosterUseCase _listCachedRoster;
  final SyncMemberRosterUseCase? _syncRoster;
  final String _tenantId;
  final bool Function() _isOnline;

  Future<void> load() async {
    emit(state.copyWith(status: MemberRosterStatus.loading));
    try {
      final members = await _listCachedRoster(tenantId: _tenantId);
      emit(
        state.copyWith(
          status: MemberRosterStatus.ready,
          members: members,
          showingCachedOffline: !_isOnline(),
          clearError: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: MemberRosterStatus.failure,
          showingCachedOffline: !_isOnline(),
          errorKey: 'members.error.roster',
        ),
      );
    }
  }

  /// Cloud sync then reload cache (FEAT-59 on Members open; FEAT-13 after enroll).
  ///
  /// Offline: reload Drift only — never pretend cloud refresh succeeded.
  /// Sync errors are surfaced (empty cache is not shown as a healthy roster).
  Future<void> refreshFromCloud() async {
    String? errorKey;
    final sync = _syncRoster;
    if (sync != null && _isOnline()) {
      try {
        await sync(tenantId: _tenantId);
      } on MemberRosterFailure catch (error) {
        errorKey = error.messageKey;
      } catch (_) {
        errorKey = 'access_scanner.roster.error.unknown';
      }
    }
    await load();
    if (errorKey == null || isClosed) return;
    // A 200 roster in Drift must render; Retry only when the table is empty.
    if (state.members.isNotEmpty) return;
    emit(
      state.copyWith(status: MemberRosterStatus.failure, errorKey: errorKey),
    );
  }
}
