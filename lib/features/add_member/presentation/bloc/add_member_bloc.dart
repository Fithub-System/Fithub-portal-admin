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
    required SearchAthletesForDeskUseCase searchAthletes,
    required EnrollGymMemberUseCase enrollGymMember,
    required InviteMemberUseCase inviteMember,
    required ListMembershipPlansUseCase listPlans,
    required AssignMembershipUseCase assignMembership,
  }) : _findAthlete = findAthlete,
       _searchAthletes = searchAthletes,
       _enrollGymMember = enrollGymMember,
       _inviteMember = inviteMember,
       _listPlans = listPlans,
       _assignMembership = assignMembership,
       super(const AddMemberState()) {
    on<AddMemberStarted>(_onStarted);
    on<AddMemberFindRequested>(_onFind);
    on<AddMemberSearchRequested>(_onSearch);
    on<AddMemberMatchSelected>(_onMatchSelected);
    on<AddMemberWizardStepChanged>(_onWizardStep);
    on<AddMemberPlanSelected>(_onPlanSelected);
    on<AddMemberInvitePlanSelected>(_onInvitePlanSelected);
    on<AddMemberEnrollRequested>(_onEnroll);
    on<AddMemberInviteRequested>(_onInvite);
    on<AddMemberMessageCleared>(_onMessageCleared);
    on<AddMemberReset>(_onReset);
  }

  final FindAthleteForEnrollUseCase _findAthlete;
  final SearchAthletesForDeskUseCase _searchAthletes;
  final EnrollGymMemberUseCase _enrollGymMember;
  final InviteMemberUseCase _inviteMember;
  final ListMembershipPlansUseCase _listPlans;
  final AssignMembershipUseCase _assignMembership;

  Future<void> _onStarted(
    AddMemberStarted event,
    Emitter<AddMemberState> emit,
  ) async {
    emit(
      state.copyWith(status: AddMemberStatus.loadingPlans, clearMessage: true),
    );
    try {
      final plans = await _listPlans(activeOnly: true);
      emit(state.copyWith(status: AddMemberStatus.idle, plans: plans));
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
        query: email,
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
          matches: [match],
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

  Future<void> _onSearch(
    AddMemberSearchRequested event,
    Emitter<AddMemberState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(
        state.copyWith(
          status: AddMemberStatus.idle,
          query: '',
          clearMatch: true,
          clearMatches: true,
          clearMessage: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: AddMemberStatus.finding,
        query: query,
        email: query.contains('@') ? query : state.email,
        clearMatch: true,
        clearMatches: true,
        clearMessage: true,
      ),
    );

    try {
      var matches = await _searchAthletes(query);
      if (matches.isEmpty && query.contains('@')) {
        final found = await _findAthlete(query);
        if (found != null) {
          matches = [found];
        }
      }
      final selected = matches.length == 1 ? matches.first : null;
      emit(
        state.copyWith(
          status: matches.isEmpty
              ? AddMemberStatus.idle
              : AddMemberStatus.found,
          matches: matches,
          match: selected,
          clearMatch: selected == null,
        ),
      );
    } on AddMemberFailure catch (e) {
      emit(
        state.copyWith(
          status: AddMemberStatus.idle,
          clearMatch: true,
          clearMatches: true,
          messageKey: e.messageKey,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AddMemberStatus.idle,
          clearMatch: true,
          clearMatches: true,
          messageKey: 'add_member.error.unknown',
        ),
      );
    }
  }

  void _onMatchSelected(
    AddMemberMatchSelected event,
    Emitter<AddMemberState> emit,
  ) {
    emit(
      state.copyWith(
        match: event.match,
        status: event.match == null
            ? AddMemberStatus.idle
            : AddMemberStatus.found,
        clearMatch: event.match == null,
        clearMessage: true,
      ),
    );
  }

  void _onWizardStep(
    AddMemberWizardStepChanged event,
    Emitter<AddMemberState> emit,
  ) {
    final step = event.step.clamp(1, 2);
    emit(state.copyWith(wizardStep: step, clearMessage: true));
  }

  void _onPlanSelected(
    AddMemberPlanSelected event,
    Emitter<AddMemberState> emit,
  ) {
    emit(
      state.copyWith(
        selectedPlanId: event.planId,
        invitePlanId: event.planId,
        clearPlan: event.planId == null,
        clearInvitePlan: event.planId == null,
      ),
    );
  }

  void _onInvitePlanSelected(
    AddMemberInvitePlanSelected event,
    Emitter<AddMemberState> emit,
  ) {
    emit(
      state.copyWith(
        invitePlanId: event.planId,
        selectedPlanId: event.planId,
        clearInvitePlan: event.planId == null,
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

    emit(state.copyWith(status: AddMemberStatus.enrolling, clearMessage: true));

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
        state.copyWith(status: AddMemberStatus.found, messageKey: e.messageKey),
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

  Future<void> _onInvite(
    AddMemberInviteRequested event,
    Emitter<AddMemberState> emit,
  ) async {
    emit(state.copyWith(status: AddMemberStatus.inviting, clearMessage: true));

    try {
      await _inviteMember(
        identifier: event.identifier,
        displayName: event.displayName,
        planId: state.invitePlanId ?? state.selectedPlanId,
      );
      emit(
        state.copyWith(
          status: AddMemberStatus.idle,
          messageKey: 'add_member.success.invite_sent',
          clearInvitePlan: true,
        ),
      );
    } on AddMemberFailure catch (e) {
      emit(
        state.copyWith(status: AddMemberStatus.idle, messageKey: e.messageKey),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AddMemberStatus.idle,
          messageKey: 'add_member.error.invite_failed',
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
    emit(AddMemberState(status: AddMemberStatus.idle, plans: state.plans));
  }
}
