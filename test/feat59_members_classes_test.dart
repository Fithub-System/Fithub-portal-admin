import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fithub_portal_admin/core/network/cloud_mutation_guard.dart';
import 'package:fithub_portal_admin/features/access_scanner/domain/entities/member_roster_entry.dart';
import 'package:fithub_portal_admin/features/access_scanner/domain/repositories/member_roster_repository.dart';
import 'package:fithub_portal_admin/features/access_scanner/domain/use_cases/sync_member_roster_use_case.dart';
import 'package:fithub_portal_admin/features/add_member/domain/repositories/add_member_repository.dart';
import 'package:fithub_portal_admin/features/add_member/domain/use_cases/add_member_use_cases.dart';
import 'package:fithub_portal_admin/features/add_member/presentation/bloc/add_member_bloc.dart';
import 'package:fithub_portal_admin/features/add_member/presentation/screens/add_member_screen.dart';
import 'package:fithub_portal_admin/features/class_sessions/domain/entities/class_session.dart';
import 'package:fithub_portal_admin/features/class_sessions/domain/repositories/class_sessions_repository.dart';
import 'package:fithub_portal_admin/features/class_sessions/domain/use_cases/class_sessions_use_cases.dart';
import 'package:fithub_portal_admin/features/class_sessions/presentation/cubit/class_sessions_cubit.dart';
import 'package:fithub_portal_admin/features/class_sessions/presentation/screens/class_manager_screen.dart';
import 'package:fithub_portal_admin/features/class_sessions/presentation/widgets/class_weekly_schedule_grid.dart';
import 'package:fithub_portal_admin/features/members/domain/use_cases/list_cached_member_roster_use_case.dart';
import 'package:fithub_portal_admin/features/members/presentation/cubit/member_roster_cubit.dart';
import 'package:fithub_portal_admin/features/members/presentation/screens/member_management_screen.dart';
import 'package:fithub_portal_admin/features/memberships/domain/repositories/memberships_repository.dart';
import 'package:fithub_portal_admin/features/memberships/domain/use_cases/memberships_use_cases.dart';
import 'package:fithub_portal_admin/features/memberships/presentation/cubit/memberships_cubit.dart';
import 'package:mocktail/mocktail.dart';

import 'support/localized_pump.dart';

class _MockRosterRepo extends Mock implements MemberRosterRepository {}

class _MockAddMemberRepo extends Mock implements AddMemberRepository {}

class _MockMembershipsRepo extends Mock implements MembershipsRepository {}

class _MockMembershipsCubit extends Mock implements MembershipsCubit {}

class _MockMemberRosterCubit extends Mock implements MemberRosterCubit {}

class _MockClassRepo extends Mock implements ClassSessionsRepository {}

void main() {
  group('FEAT-59 US-A MemberRosterCubit refreshFromCloud', () {
    late _MockRosterRepo roster;

    setUp(() {
      roster = _MockRosterRepo();
    });

    test('refreshFromCloud syncs then presents live rows', () async {
      when(() => roster.syncRoster(tenantId: 't1')).thenAnswer((_) async => 1);
      when(() => roster.listCachedMembers(tenantId: 't1')).thenAnswer(
        (_) async => [
          MemberRosterEntry(
            id: 'live-1',
            fullName: 'Live Member',
            powerScore: 50,
            cryptoSalt: 'salt',
            createdAt: DateTime.utc(2026, 1, 1),
          ),
        ],
      );

      final cubit = MemberRosterCubit(
        listCachedRoster: ListCachedMemberRosterUseCase(roster),
        syncRoster: SyncMemberRosterUseCase(roster),
        tenantId: 't1',
        isOnline: () => true,
      );
      await cubit.refreshFromCloud();

      verify(() => roster.syncRoster(tenantId: 't1')).called(1);
      verify(() => roster.listCachedMembers(tenantId: 't1')).called(1);
      expect(cubit.state.status, MemberRosterStatus.ready);
      expect(cubit.state.members.single.fullName, 'Live Member');
      await cubit.close();
    });

    test('refreshFromCloud empty live roster stays empty (no fixtures)', () async {
      when(() => roster.syncRoster(tenantId: 't1')).thenAnswer((_) async => 0);
      when(
        () => roster.listCachedMembers(tenantId: 't1'),
      ).thenAnswer((_) async => []);

      final cubit = MemberRosterCubit(
        listCachedRoster: ListCachedMemberRosterUseCase(roster),
        syncRoster: SyncMemberRosterUseCase(roster),
        tenantId: 't1',
        isOnline: () => true,
      );
      await cubit.refreshFromCloud();

      expect(cubit.state.status, MemberRosterStatus.ready);
      expect(cubit.state.members, isEmpty);
      await cubit.close();
    });
  });

  group('FEAT-59 US-A empty Members chrome', () {
    late _MockMembershipsCubit membershipsCubit;
    late _MockMemberRosterCubit rosterCubit;

    setUp(() {
      membershipsCubit = _MockMembershipsCubit();
      rosterCubit = _MockMemberRosterCubit();

      when(() => membershipsCubit.state).thenReturn(
        const MembershipsState(status: MembershipsStatus.ready, plans: []),
      );
      when(() => membershipsCubit.stream).thenAnswer(
        (_) => Stream.value(
          const MembershipsState(status: MembershipsStatus.ready, plans: []),
        ),
      );

      when(() => rosterCubit.state).thenReturn(
        const MemberRosterState(status: MemberRosterStatus.ready),
      );
      when(() => rosterCubit.stream).thenAnswer(
        (_) => Stream.value(
          const MemberRosterState(status: MemberRosterStatus.ready),
        ),
      );
      when(() => rosterCubit.refreshFromCloud()).thenAnswer((_) async {});
    });

    testWidgets('empty live roster shows empty chrome not Stitch samples', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await pumpLocalizedApp(
        tester,
        MultiBlocProvider(
          providers: [
            BlocProvider<MembershipsCubit>.value(value: membershipsCubit),
            BlocProvider<MemberRosterCubit>.value(value: rosterCubit),
          ],
          child: const MemberManagementScreen(
            canWrite: true,
            canEnroll: true,
          ),
        ),
        waitFor: find.textContaining('No members in this gym'),
      );

      expect(find.text('Dominic Russo'), findsNothing);
      expect(find.text('Sarah Miller'), findsNothing);
      expect(find.textContaining('No members in this gym'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('failure banner retry calls refreshFromCloud', (tester) async {
      const failure = MemberRosterState(
        status: MemberRosterStatus.failure,
      );
      when(() => rosterCubit.state).thenReturn(failure);
      when(() => rosterCubit.stream).thenAnswer((_) => Stream.value(failure));

      await pumpLocalizedApp(
        tester,
        MultiBlocProvider(
          providers: [
            BlocProvider<MembershipsCubit>.value(value: membershipsCubit),
            BlocProvider<MemberRosterCubit>.value(value: rosterCubit),
          ],
          child: const MemberManagementScreen(canWrite: true),
        ),
        waitFor: find.textContaining('Could not refresh members'),
      );

      await tester.tap(find.text('Retry').first);
      await tester.pump();
      verify(() => rosterCubit.refreshFromCloud()).called(greaterThan(0));
    });
  });

  group('FEAT-59 US-B Add Member centered', () {
    test('cites Stitch EN+AR and formMaxWidth 720', () {
      expect(AddMemberScreen.formMaxWidth, 720);
      expect(
        AddMemberScreen.stitchScreenIdEn,
        'cd59a129a24449478a5249ccb41635fb',
      );
      expect(
        AddMemberScreen.stitchScreenIdAr,
        '89fe5d7afb8d4d4384d7e6498bcdd065',
      );
    });

    testWidgets('wide viewport centers ConstrainedBox form shell', (
      tester,
    ) async {
      final addRepo = _MockAddMemberRepo();
      final membershipsRepo = _MockMembershipsRepo();
      when(
        () => membershipsRepo.listPlans(activeOnly: any(named: 'activeOnly')),
      ).thenAnswer((_) async => []);

      final bloc = AddMemberBloc(
        findAthlete: FindAthleteForEnrollUseCase(addRepo),
        enrollGymMember: EnrollGymMemberUseCase(addRepo),
        listPlans: ListMembershipPlansUseCase(membershipsRepo),
        assignMembership: AssignMembershipUseCase(membershipsRepo),
      );
      addTearDown(bloc.close);

      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await pumpLocalizedApp(
        tester,
        BlocProvider<AddMemberBloc>.value(
          value: bloc,
          child: const AddMemberScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      final boxes = tester.widgetList<ConstrainedBox>(
        find.byType(ConstrainedBox),
      );
      expect(
        boxes.any(
          (b) => b.constraints.maxWidth == AddMemberScreen.formMaxWidth,
        ),
        isTrue,
      );

      final centered = find.byWidgetPredicate(
        (w) =>
            w is Align &&
            w.alignment == Alignment.topCenter &&
            w.child is ConstrainedBox &&
            (w.child! as ConstrainedBox).constraints.maxWidth ==
                AddMemberScreen.formMaxWidth,
      );
      expect(centered, findsOneWidget);
    });
  });

  group('FEAT-59 US-C Classes empty-slot Schedule New', () {
    late _MockClassRepo repository;
    final fixedNow = DateTime(2023, 10, 25, 12);

    setUpAll(() {
      registerFallbackValue(DateTime(2023, 1, 1));
    });

    setUp(() {
      repository = _MockClassRepo();
      when(() => repository.listSessions()).thenAnswer((_) async => []);
      when(() => repository.listCoaches()).thenAnswer((_) async => []);
    });

    ClassSessionsCubit buildCubit() {
      return ClassSessionsCubit(
        listSessions: ListClassSessionsUseCase(repository),
        listCoaches: ListClassCoachesUseCase(repository),
        upsertSession: UpsertClassSessionUseCase(
          repository,
          cloudGuard: CloudMutationGuard(isOnline: () => true),
        ),
        clock: () => fixedNow,
      );
    }

    testWidgets('hover reveals Schedule New on non-Wed empty cell', (
      tester,
    ) async {
      final cubit = buildCubit();
      addTearDown(cubit.close);
      await tester.binding.setSurfaceSize(const Size(1400, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await pumpLocalizedApp(
        tester,
        BlocProvider<ClassSessionsCubit>.value(
          value: cubit,
          child: const ClassManagerScreen(canWrite: true),
        ),
        waitFor: find.text('WEEKLY SCHEDULE'),
      );

      expect(find.text('SCHEDULE NEW'), findsNothing);

      final mouseRegions = find.descendant(
        of: find.byType(ClassWeeklyScheduleGrid),
        matching: find.byType(MouseRegion),
      );
      expect(mouseRegions, findsWidgets);

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(tester.getCenter(mouseRegions.first));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.text('SCHEDULE NEW'), findsWidgets);
    });

    testWidgets('tap empty slot still opens schedule path (form focus)', (
      tester,
    ) async {
      when(() => repository.listSessions()).thenAnswer(
        (_) async => [
          ClassSession(
            id: 's1',
            tenantId: 't1',
            title: 'Power Yoga',
            startsAt: DateTime(2023, 10, 23, 6),
            endsAt: DateTime(2023, 10, 23, 7),
            capacity: 20,
            status: 'scheduled',
          ),
        ],
      );
      final cubit = buildCubit();
      addTearDown(cubit.close);
      await tester.binding.setSurfaceSize(const Size(1400, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await pumpLocalizedApp(
        tester,
        BlocProvider<ClassSessionsCubit>.value(
          value: cubit,
          child: const ClassManagerScreen(canWrite: true),
        ),
        waitFor: find.text('WEEKLY SCHEDULE'),
      );

      final addIcons = find.byIcon(Icons.add);
      expect(addIcons, findsWidgets);
      await tester.tap(addIcons.at(1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('ADD NEW SESSION'), findsOneWidget);
    });
  });
}
