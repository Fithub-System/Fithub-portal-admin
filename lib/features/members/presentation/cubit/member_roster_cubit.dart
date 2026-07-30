import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../access_scanner/domain/entities/member_roster_entry.dart';
import '../../domain/use_cases/list_cached_member_roster_use_case.dart';

part 'member_roster_state.dart';

class MemberRosterCubit extends Cubit<MemberRosterState> {
  MemberRosterCubit({
    required ListCachedMemberRosterUseCase listCachedRoster,
    required String tenantId,
  }) : _listCachedRoster = listCachedRoster,
       _tenantId = tenantId,
       super(const MemberRosterState());

  final ListCachedMemberRosterUseCase _listCachedRoster;
  final String _tenantId;

  Future<void> load() async {
    emit(state.copyWith(status: MemberRosterStatus.loading));
    try {
      final members = await _listCachedRoster(tenantId: _tenantId);
      emit(
        state.copyWith(
          status: MemberRosterStatus.ready,
          members: members,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: MemberRosterStatus.failure));
    }
  }
}
