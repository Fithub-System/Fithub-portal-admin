import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/freeze_policy.dart';
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
    required RenewMembershipUseCase renewMembership,
    required FreezeMembershipUseCase freezeMembership,
    required UnfreezeMembershipUseCase unfreezeMembership,
    required ListFreezePoliciesUseCase listFreezePolicies,
    required UpsertFreezePolicyUseCase upsertFreezePolicy,
  }) : _listPlans = listPlans,
       _createPlan = createPlan,
       _deactivatePlan = deactivatePlan,
       _assignMembership = assignMembership,
       _listAthletes = listAthletes,
       _renewMembership = renewMembership,
       _freezeMembership = freezeMembership,
       _unfreezeMembership = unfreezeMembership,
       _listFreezePolicies = listFreezePolicies,
       _upsertFreezePolicy = upsertFreezePolicy,
       super(const MembershipsState());

  final ListMembershipPlansUseCase _listPlans;
  final CreateMembershipPlanUseCase _createPlan;
  final DeactivateMembershipPlanUseCase _deactivatePlan;
  final AssignMembershipUseCase _assignMembership;
  final ListMembershipAthletesUseCase _listAthletes;
  final RenewMembershipUseCase _renewMembership;
  final FreezeMembershipUseCase _freezeMembership;
  final UnfreezeMembershipUseCase _unfreezeMembership;
  final ListFreezePoliciesUseCase _listFreezePolicies;
  final UpsertFreezePolicyUseCase _upsertFreezePolicy;

  Future<void> load() async {
    emit(state.copyWith(status: MembershipsStatus.loading, clearMessage: true));
    try {
      final plans = await _listPlans();
      final athletes = await _listAthletes();
      List<FreezePolicy> policies = const [];
      try {
        policies = await _listFreezePolicies();
      } catch (_) {
        // Policies optional for plan CRUD; freeze UI treats empty as disabled.
      }
      emit(
        state.copyWith(
          status: MembershipsStatus.ready,
          plans: plans,
          athletes: athletes,
          freezePolicies: policies,
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

  Future<void> loadFreezePolicies() async {
    try {
      final policies = await _listFreezePolicies();
      emit(state.copyWith(freezePolicies: policies));
    } on MembershipsFailure catch (e) {
      emit(state.copyWith(messageKey: e.messageKey));
    } catch (_) {
      emit(
        state.copyWith(
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

  /// Returns i18n key for snackbar (success or error).
  Future<String> renewMembership(String membershipId) async {
    emit(state.copyWith(busy: true, clearMessage: true));
    try {
      await _renewMembership(membershipId);
      emit(state.copyWith(busy: false));
      return 'members.success.renewed';
    } on MembershipsFailure catch (e) {
      emit(state.copyWith(busy: false));
      return e.messageKey;
    } catch (_) {
      emit(state.copyWith(busy: false));
      return const MembershipsUnknownFailure().messageKey;
    }
  }

  Future<String> freezeMembership({
    required String membershipId,
    int? days,
  }) async {
    emit(state.copyWith(busy: true, clearMessage: true));
    try {
      await _freezeMembership(membershipId: membershipId, days: days);
      emit(state.copyWith(busy: false));
      return 'members.success.frozen';
    } on MembershipsFailure catch (e) {
      emit(state.copyWith(busy: false));
      return e.messageKey;
    } catch (_) {
      emit(state.copyWith(busy: false));
      return const MembershipsUnknownFailure().messageKey;
    }
  }

  Future<String> unfreezeMembership(String membershipId) async {
    emit(state.copyWith(busy: true, clearMessage: true));
    try {
      await _unfreezeMembership(membershipId);
      emit(state.copyWith(busy: false));
      return 'members.success.unfrozen';
    } on MembershipsFailure catch (e) {
      emit(state.copyWith(busy: false));
      return e.messageKey;
    } catch (_) {
      emit(state.copyWith(busy: false));
      return const MembershipsUnknownFailure().messageKey;
    }
  }

  Future<String> upsertFreezePolicy({
    required int freezeDays,
    required int maxFreezeDaysPerTime,
    String? planId,
  }) async {
    emit(state.copyWith(busy: true, clearMessage: true));
    try {
      await _upsertFreezePolicy(
        freezeDays: freezeDays,
        maxFreezeDaysPerTime: maxFreezeDaysPerTime,
        planId: planId,
      );
      final policies = await _listFreezePolicies();
      emit(
        state.copyWith(
          busy: false,
          freezePolicies: policies,
          messageKey: 'gym_settings.freeze.success.saved',
        ),
      );
      return 'gym_settings.freeze.success.saved';
    } on ArgumentError {
      emit(state.copyWith(busy: false));
      return 'gym_settings.freeze.error.invalid';
    } on MembershipsFailure catch (e) {
      emit(state.copyWith(busy: false, messageKey: e.messageKey));
      return e.messageKey;
    } catch (_) {
      emit(state.copyWith(busy: false));
      return const MembershipsUnknownFailure().messageKey;
    }
  }
}
