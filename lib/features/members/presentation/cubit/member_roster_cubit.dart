import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../access_scanner/domain/entities/member_roster_entry.dart';
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
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: MemberRosterStatus.failure,
          showingCachedOffline: !_isOnline(),
        ),
      );
    }
  }

  /// Cloud sync then reload cache (FEAT-13 after enroll).
  ///
  /// Offline: reload Drift only — never pretend cloud refresh succeeded.
  Future<void> refreshFromCloud() async {
    final sync = _syncRoster;
    if (sync != null && _isOnline()) {
      try {
        await sync(tenantId: _tenantId);
      } catch (_) {
        // Still attempt cache reload below.
      }
    }
    await load();
  }
}
