import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/staff_invite.dart';
import '../../domain/entities/staff_role.dart';
import '../../domain/staff_invite_failure.dart';
import '../../domain/use_cases/staff_invite_use_case.dart';

part 'staff_invite_event.dart';
part 'staff_invite_state.dart';

class StaffInviteBloc extends Bloc<StaffInviteEvent, StaffInviteState> {
  StaffInviteBloc({required InviteStaffUseCase inviteStaffUseCase})
    : _inviteStaff = inviteStaffUseCase,
      super(const StaffInviteFormState()) {
    on<StaffInviteRoleSelected>(_onRoleSelected);
    on<StaffInviteSubmitted>(_onSubmitted);
    on<StaffInviteMessageCleared>(_onMessageCleared);
  }

  final InviteStaffUseCase _inviteStaff;

  void _onRoleSelected(
    StaffInviteRoleSelected event,
    Emitter<StaffInviteState> emit,
  ) {
    emit(StaffInviteFormState(selectedRole: event.role));
  }

  Future<void> _onSubmitted(
    StaffInviteSubmitted event,
    Emitter<StaffInviteState> emit,
  ) async {
    final role = state.selectedRole;
    emit(StaffInviteSubmitting(selectedRole: role));
    try {
      final result = await _inviteStaff(
        StaffInvite(email: event.email, role: role, name: event.name),
      );
      emit(StaffInviteSuccess(selectedRole: role, result: result));
    } on StaffInviteFailure catch (e) {
      emit(
        StaffInviteFormState(
          selectedRole: role,
          messageKey:
              e.message.startsWith('staff_invite.') ||
                  e.message.startsWith('validation.')
              ? e.message
              : null,
          messageText:
              e.message.startsWith('staff_invite.') ||
                  e.message.startsWith('validation.')
              ? null
              : e.message,
        ),
      );
    } catch (_) {
      emit(
        StaffInviteFormState(
          selectedRole: role,
          messageKey: 'staff_invite.error.unknown',
        ),
      );
    }
  }

  void _onMessageCleared(
    StaffInviteMessageCleared event,
    Emitter<StaffInviteState> emit,
  ) {
    emit(StaffInviteFormState(selectedRole: state.selectedRole));
  }
}
