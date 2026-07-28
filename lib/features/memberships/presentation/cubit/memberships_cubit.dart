import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/membership_plan.dart';
import '../../domain/memberships_failure.dart';
import '../../domain/use_cases/memberships_use_cases.dart';

part 'memberships_state.dart';

class MembershipsCubit extends Cubit<MembershipsState> {
  MembershipsCubit({
    required ListMembershipPlansUseCase listPlans,
    required CreateMembershipPlanUseCase createPlan,
    required DeactivateMembershipPlanUseCase deactivatePlan,
    required AssignMembershipUseCase assignMembership,
    required ListMembershipAthletesUseCase listAthletes,
  }) : _listPlans = listPlans,
       _createPlan = createPlan,
       _deactivatePlan = deactivatePlan,
       _assignMembership = assignMembership,
       _listAthletes = listAthletes,
       super(const MembershipsState());

  final ListMembershipPlansUseCase _listPlans;
  final CreateMembershipPlanUseCase _createPlan;
  final DeactivateMembershipPlanUseCase _deactivatePlan;
  final AssignMembershipUseCase _assignMembership;
  final ListMembershipAthletesUseCase _listAthletes;

  Future<void> load() async {
    emit(state.copyWith(status: MembershipsStatus.loading, clearMessage: true));
    try {
      final plans = await _listPlans();
      final athletes = await _listAthletes();
      emit(
        state.copyWith(
          status: MembershipsStatus.ready,
          plans: plans,
          athletes: athletes,
        ),
      );
    } on MembershipsFailure catch (e) {
      emit(
        state.copyWith(
          status: MembershipsStatus.failure,
          messageKey: e.messageKey,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: MembershipsStatus.failure,
          messageKey: const MembershipsUnknownFailure().messageKey,
        ),
      );
    }
  }

  Future<void> createPlan({
    required String name,
    String? description,
    required int durationDays,
    required int priceCents,
  }) async {
    emit(state.copyWith(busy: true, clearMessage: true));
    try {
      await _createPlan(
        name: name,
        description: description,
        durationDays: durationDays,
        priceCents: priceCents,
      );
      final plans = await _listPlans();
      emit(
        state.copyWith(
          busy: false,
          plans: plans,
          messageKey: 'memberships.success.plan_created',
        ),
      );
    } on MembershipsFailure catch (e) {
      emit(state.copyWith(busy: false, messageKey: e.messageKey));
    } catch (_) {
      emit(
        state.copyWith(
          busy: false,
          messageKey: const MembershipsUnknownFailure().messageKey,
        ),
      );
    }
  }

  Future<void> deactivatePlan(String planId) async {
    emit(state.copyWith(busy: true, clearMessage: true));
    try {
      await _deactivatePlan(planId);
      final plans = await _listPlans();
      emit(
        state.copyWith(
          busy: false,
          plans: plans,
          messageKey: 'memberships.success.plan_deactivated',
        ),
      );
    } on MembershipsFailure catch (e) {
      emit(state.copyWith(busy: false, messageKey: e.messageKey));
    } catch (_) {
      emit(
        state.copyWith(
          busy: false,
          messageKey: const MembershipsUnknownFailure().messageKey,
        ),
      );
    }
  }

  Future<void> assign({
    required String planId,
    required String athleteId,
  }) async {
    emit(state.copyWith(busy: true, clearMessage: true));
    try {
      await _assignMembership(planId: planId, athleteId: athleteId);
      emit(
        state.copyWith(
          busy: false,
          messageKey: 'memberships.success.assigned',
        ),
      );
    } on MembershipsFailure catch (e) {
      emit(state.copyWith(busy: false, messageKey: e.messageKey));
    } catch (_) {
      emit(
        state.copyWith(
          busy: false,
          messageKey: const MembershipsUnknownFailure().messageKey,
        ),
      );
    }
  }
}
