import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../memberships/domain/entities/membership_plan.dart';
import '../../../memberships/domain/memberships_failure.dart';
import '../../../memberships/domain/use_cases/memberships_use_cases.dart';
import '../../domain/add_member_failure.dart';
import '../../domain/entities/athlete_enroll_match.dart';
import '../../domain/use_cases/add_member_use_cases.dart';

part 'add_member_event.dart';
part 'add_member_state.dart';

class AddMemberBloc extends Bloc<AddMemberEvent, AddMemberState> {
  AddMemberBloc({
    required FindAthleteForEnrollUseCase findAthlete,
    required EnrollGymMemberUseCase enrollGymMember,
    required ListMembershipPlansUseCase listPlans,
    required AssignMembershipUseCase assignMembership,
  }) : _findAthlete = findAthlete,
       _enrollGymMember = enrollGymMember,
       _listPlans = listPlans,
       _assignMembership = assignMembership,
       super(const AddMemberState()) {
    on<AddMemberStarted>(_onStarted);
    on<AddMemberFindRequested>(_onFind);
    on<AddMemberPlanSelected>(_onPlanSelected);
    on<AddMemberEnrollRequested>(_onEnroll);
    on<AddMemberMessageCleared>(_onMessageCleared);
    on<AddMemberReset>(_onReset);
  }

  final FindAthleteForEnrollUseCase _findAthlete;
  final EnrollGymMemberUseCase _enrollGymMember;
  final ListMembershipPlansUseCase _listPlans;
  final AssignMembershipUseCase _assignMembership;

  Future<void> _onStarted(
    AddMemberStarted event,
    Emitter<AddMemberState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AddMemberStatus.loadingPlans,
        clearMessage: true,
      ),
    );
    try {
      final plans = await _listPlans(activeOnly: true);
      emit(
        state.copyWith(
          status: AddMemberStatus.idle,
          plans: plans,
        ),
      );
    } on MembershipsFailure catch (e) {
      emit(
        state.copyWith(
          status: AddMemberStatus.idle,
          plans: const [],
          messageKey: e.messageKey,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AddMemberStatus.idle,
          plans: const [],
          messageKey: 'add_member.error.unknown',
        ),
      );
    }
  }

  Future<void> _onFind(
    AddMemberFindRequested event,
    Emitter<AddMemberState> emit,
  ) async {
    final email = event.email.trim();
    if (email.isEmpty || !email.contains('@')) {
      emit(
        state.copyWith(
          status: AddMemberStatus.idle,
          clearMatch: true,
          messageKey: 'add_member.validation.email',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: AddMemberStatus.finding,
        email: email,
        clearMatch: true,
        clearMessage: true,
      ),
    );

    try {
      final match = await _findAthlete(email);
      if (match == null) {
        emit(
          state.copyWith(
            status: AddMemberStatus.idle,
            clearMatch: true,
            messageKey: 'add_member.error.not_found',
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          status: AddMemberStatus.found,
          match: match,
        ),
      );
    } on AddMemberFailure catch (e) {
      emit(
        state.copyWith(
          status: AddMemberStatus.idle,
          clearMatch: true,
          messageKey: e.messageKey,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AddMemberStatus.idle,
          clearMatch: true,
          messageKey: 'add_member.error.unknown',
        ),
      );
    }
  }

  void _onPlanSelected(
    AddMemberPlanSelected event,
    Emitter<AddMemberState> emit,
  ) {
    emit(
      state.copyWith(
        selectedPlanId: event.planId,
        clearPlan: event.planId == null,
      ),
    );
  }

  Future<void> _onEnroll(
    AddMemberEnrollRequested event,
    Emitter<AddMemberState> emit,
  ) async {
    final match = state.match;
    if (match == null) {
      emit(state.copyWith(messageKey: 'add_member.error.not_found'));
      return;
    }

    emit(
      state.copyWith(
        status: AddMemberStatus.enrolling,
        clearMessage: true,
      ),
    );

    try {
      final enroll = await _enrollGymMember(match.id);
      final planId = state.selectedPlanId;
      if (planId != null && planId.isNotEmpty) {
        try {
          await _assignMembership(planId: planId, athleteId: match.id);
        } on MembershipsFailure catch (e) {
          emit(
            state.copyWith(
              status: AddMemberStatus.success,
              enrollCreated: enroll.created,
              messageKey: e.messageKey,
              assignFailed: true,
            ),
          );
          return;
        }
      }
      emit(
        state.copyWith(
          status: AddMemberStatus.success,
          enrollCreated: enroll.created,
          messageKey: enroll.created
              ? 'add_member.success.enrolled'
              : 'add_member.success.already_enrolled',
        ),
      );
    } on AddMemberFailure catch (e) {
      emit(
        state.copyWith(
          status: AddMemberStatus.found,
          messageKey: e.messageKey,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AddMemberStatus.found,
          messageKey: 'add_member.error.unknown',
        ),
      );
    }
  }

  void _onMessageCleared(
    AddMemberMessageCleared event,
    Emitter<AddMemberState> emit,
  ) {
    emit(state.copyWith(clearMessage: true));
  }

  void _onReset(AddMemberReset event, Emitter<AddMemberState> emit) {
    emit(
      AddMemberState(
        status: AddMemberStatus.idle,
        plans: state.plans,
      ),
    );
  }
}
