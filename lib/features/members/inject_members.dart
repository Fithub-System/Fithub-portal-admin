import 'package:get_it/get_it.dart';

import '../../core/network/connectivity_service.dart';
import '../access_scanner/domain/repositories/member_roster_repository.dart';
import '../access_scanner/domain/use_cases/sync_member_roster_use_case.dart';
import 'domain/use_cases/list_cached_member_roster_use_case.dart';
import 'presentation/cubit/member_roster_cubit.dart';

/// Members feature DI (FEAT-07-R).
void registerMembersDependencies(GetIt getIt) {
  if (!getIt.isRegistered<ListCachedMemberRosterUseCase>()) {
    getIt.registerLazySingleton(
      () => ListCachedMemberRosterUseCase(getIt<MemberRosterRepository>()),
    );
  }
}

MemberRosterCubit createMemberRosterCubit({
  required GetIt getIt,
  required String tenantId,
}) {
  return MemberRosterCubit(
    listCachedRoster: getIt<ListCachedMemberRosterUseCase>(),
    syncRoster: getIt.isRegistered<SyncMemberRosterUseCase>()
        ? getIt<SyncMemberRosterUseCase>()
        : null,
    tenantId: tenantId,
    isOnline: getIt.isRegistered<ConnectivityService>()
        ? () => getIt<ConnectivityService>().isOnline
        : null,
  );
}
