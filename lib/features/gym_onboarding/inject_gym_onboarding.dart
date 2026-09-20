import 'package:get_it/get_it.dart';

import 'package:fithub_portal_admin/features/gym_onboarding/data/gym_onboarding_remote.dart';
import 'package:fithub_portal_admin/features/gym_onboarding/presentation/gym_onboarding_cubit.dart';
import 'package:fithub_portal_admin/features/memberships/domain/use_cases/memberships_use_cases.dart';
import 'package:fithub_portal_admin/features/staff_invite/domain/use_cases/staff_invite_use_case.dart';

void registerGymOnboardingDependencies(GetIt getIt) {
  if (!getIt.isRegistered<GymOnboardingRemote>()) {
    getIt.registerLazySingleton(
      () => GymOnboardingRemote(
        createPlan: getIt<CreateMembershipPlanUseCase>(),
        inviteStaff: getIt<InviteStaffUseCase>(),
      ),
    );
  }
  if (!getIt.isRegistered<GymOnboardingCubit>()) {
    getIt.registerFactory(
      () => GymOnboardingCubit(remote: getIt<GymOnboardingRemote>()),
    );
  }
}
