import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fithub_portal_admin/core/network/cloud_mutation_guard.dart';
import 'package:fithub_portal_admin/features/auth/domain/entities/employee_profile.dart';
import 'package:fithub_portal_admin/features/class_sessions/domain/class_sessions_failure.dart';
import 'package:fithub_portal_admin/features/class_sessions/domain/entities/class_session.dart';
import 'package:fithub_portal_admin/features/class_sessions/domain/repositories/class_sessions_repository.dart';
import 'package:fithub_portal_admin/features/class_sessions/domain/use_cases/class_sessions_use_cases.dart';
import 'package:fithub_portal_admin/features/class_sessions/presentation/cubit/class_sessions_cubit.dart';
import 'package:fithub_portal_admin/features/class_sessions/presentation/fixtures/class_manager_stitch_fixtures.dart';
import 'package:fithub_portal_admin/features/class_sessions/presentation/screens/class_manager_screen.dart';
import 'package:fithub_portal_admin/features/home/presentation/pages/portal_shell_destinations.dart';
import 'package:fithub_portal_admin/features/home/presentation/widgets/kinetic_coming_soon_empty.dart';
import 'package:mocktail/mocktail.dart';

import 'support/localized_pump.dart';

class _MockRepo extends Mock implements ClassSessionsRepository {}

void main() {
  late _MockRepo repository;
  final fixedNow = DateTime(2023, 10, 25, 12);

  setUpAll(() {
    registerFallbackValue(DateTime(2023, 1, 1));
  });

  setUp(() {
    repository = _MockRepo();
  });

  ClassSessionsCubit buildCubit() {
    return ClassSessionsCubit(
      listSessions: ListClassSessionsUseCase(repository),
      listCoaches: ListClassCoachesUseCase(repository),
      upsertSession: UpsertClassSessionUseCase(repository, cloudGuard: CloudMutationGuard(isOnline: () => true)),
      clock: () => fixedNow,
    );
  }

  group('FEAT-18 Admin gate', () {
    test('Admin can manage; Receptionist cannot', () {
      const admin = EmployeeProfile(
        id: '1',
        tenantId: 't1',
        userId: 'u1',
        name: 'A',
        role: 'Admin',
      );
      const receptionist = EmployeeProfile(
        id: '2',
        tenantId: 't1',
        userId: 'u2',
        name: 'R',
        role: 'Receptionist',
      );
      expect(admin.canManageClassSessions, isTrue);
      expect(receptionist.canManageClassSessions, isFalse);
    });
  });

  group('ClassSessionsCubit', () {
    test('load emits ready with sessions and coaches', () async {
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
      when(() => repository.listCoaches()).thenAnswer(
        (_) async => const [
          ClassCoachOption(id: 'c1', name: 'Marcus Vane', role: 'Coach'),
        ],
      );

      final cubit = buildCubit();
      await cubit.load();
      expect(cubit.state.status, ClassSessionsStatus.ready);
      expect(cubit.state.sessions, hasLength(1));
      expect(cubit.state.coaches, hasLength(1));
      expect(cubit.state.weekStart, DateTime(2023, 10, 23));
      await cubit.close();
    });

    test('create maps forbidden failure to message key', () async {
      when(() => repository.listSessions()).thenAnswer((_) async => []);
      when(() => repository.listCoaches()).thenAnswer((_) async => []);
      when(
        () => repository.upsertSession(
          id: any(named: 'id'),
          title: any(named: 'title'),
          startsAt: any(named: 'startsAt'),
          endsAt: any(named: 'endsAt'),
          capacity: any(named: 'capacity'),
          coachEmployeeId: any(named: 'coachEmployeeId'),
          status: any(named: 'status'),
        ),
      ).thenThrow(const ClassSessionsForbiddenFailure());

      final cubit = buildCubit();
      await cubit.createOrUpdate(title: 'HIIT', capacity: 25);
      expect(cubit.state.messageKey, 'classes.error.forbidden');
      await cubit.close();
    });

    test('softCancel upserts status cancelled', () async {
      final session = ClassSession(
        id: 's1',
        tenantId: 't1',
        title: 'Power Yoga',
        startsAt: DateTime(2023, 10, 23, 6),
        endsAt: DateTime(2023, 10, 23, 7),
        capacity: 20,
        status: 'scheduled',
      );
      when(() => repository.listSessions()).thenAnswer((_) async => [session]);
      when(() => repository.listCoaches()).thenAnswer((_) async => []);
      when(
        () => repository.upsertSession(
          id: any(named: 'id'),
          title: any(named: 'title'),
          startsAt: any(named: 'startsAt'),
          endsAt: any(named: 'endsAt'),
          capacity: any(named: 'capacity'),
          coachEmployeeId: any(named: 'coachEmployeeId'),
          status: any(named: 'status'),
        ),
      ).thenAnswer(
        (_) async => ClassSession(
          id: session.id,
          tenantId: session.tenantId,
          title: session.title,
          startsAt: session.startsAt,
          endsAt: session.endsAt,
          capacity: session.capacity,
          status: 'cancelled',
        ),
      );

      final cubit = buildCubit();
      await cubit.softCancel(session);
      expect(cubit.state.messageKey, 'classes.success.cancelled');
      verify(
        () => repository.upsertSession(
          id: 's1',
          title: 'Power Yoga',
          startsAt: session.startsAt,
          endsAt: session.endsAt,
          capacity: 20,
          coachEmployeeId: null,
          status: 'cancelled',
        ),
      ).called(1);
      await cubit.close();
    });
  });

  group('FEAT-18 Stitch citations', () {
    test('Class Manager cites locked EN + AR ids', () {
      expect(
        ClassManagerScreen.stitchScreenIdEn,
        '40cc7e5d1f27417f9e6681c0fe14b180',
      );
      expect(
        ClassManagerScreen.stitchScreenIdAr,
        '3f356939493b4a79980687040e5e4fa2',
      );
      expect(ClassManagerScreen.stitchScreenTitle, 'Class Manager');
      expect(ClassManagerStitchFixtures.attendees, hasLength(5));
    });

    test('Coming soon Classes ids superseded (not Classes destination)', () {
      expect(
        ClassesComingSoonPage.stitchScreenIdEn,
        isNot(ClassManagerScreen.stitchScreenIdEn),
      );
      expect(PortalShellDestinations.destinationCount, 6);
      expect(PortalShellDestinations.classes, 3);
    });
  });

  group('FEAT-18 Class Manager regions', () {
    late ClassSessionsCubit cubit;

    setUp(() {
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
      when(() => repository.listCoaches()).thenAnswer(
        (_) async => const [
          ClassCoachOption(id: 'c1', name: 'Marcus Vane', role: 'Coach'),
        ],
      );
      cubit = buildCubit();
    });

    tearDown(() async {
      await cubit.close();
    });

    testWidgets('Admin shows write CTAs and Stitch regions', (tester) async {
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

      expect(find.text('WEEKLY SCHEDULE'), findsOneWidget);
      expect(find.text('ADD NEW SESSION'), findsOneWidget);
      expect(find.text('CREATE CLASS'), findsOneWidget);

      await tester.tap(find.textContaining('POWER YOGA').first);
      await tester.pumpAndSettle();

      expect(find.text('ATTENDEE LIST'), findsOneWidget);
      expect(find.text('Alex Rivera'), findsOneWidget);
      expect(find.textContaining('POWER YOGA'), findsWidgets);
    });

    testWidgets('Receptionist hides write Schedule New / Create', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1400, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await pumpLocalizedApp(
        tester,
        BlocProvider<ClassSessionsCubit>.value(
          value: cubit,
          child: const ClassManagerScreen(canWrite: false),
        ),
        waitFor: find.text('WEEKLY SCHEDULE'),
      );

      expect(find.text('WEEKLY SCHEDULE'), findsOneWidget);
      expect(find.text('SCHEDULE NEW'), findsNothing);
      expect(
        find.textContaining('Receptionist view'),
        findsOneWidget,
      );
    });
  });
}
