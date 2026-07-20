import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import 'package:fithub_portal_admin/config/theme/kinetic_tokens.dart';
import 'package:fithub_portal_admin/features/access_scanner/domain/entities/member_roster_entry.dart';
import 'package:fithub_portal_admin/features/access_scanner/domain/member_roster_failure.dart';
import 'package:fithub_portal_admin/features/access_scanner/domain/repositories/member_roster_repository.dart';
import 'package:fithub_portal_admin/features/access_scanner/domain/use_cases/process_qr_scan_use_case.dart';
import 'package:fithub_portal_admin/features/access_scanner/domain/use_cases/sync_member_roster_use_case.dart';
import 'package:fithub_portal_admin/features/access_scanner/presentation/cubit/access_scanner_cubit.dart';
import 'package:fithub_portal_admin/features/access_scanner/presentation/cubit/access_scanner_state.dart';
import 'package:fithub_portal_admin/features/access_scanner/presentation/screens/access_scanner_screen.dart';
import 'package:fithub_portal_admin/features/auth/domain/entities/employee_profile.dart';
import 'package:fithub_portal_admin/features/auth/domain/repositories/auth_repository.dart';
import 'package:fithub_portal_admin/features/auth/presentation/bloc/auth_bloc.dart';

class _MockMemberRosterRepository extends Mock
    implements MemberRosterRepository {}

class _MockAuthRepository extends Mock implements AuthRepository {}

class _FakeSession extends Fake implements Session {}

class _MockProcessQrScan extends Mock implements ProcessQrScanUseCase {}

void main() {
  group('FEAT-01 Access Scanner', () {
    test('cites Stitch project and screen placeholder id', () {
      expect(KineticTokens.stitchProjectId, '13435235862240753621');
      expect(
        AccessScannerScreen.stitchScreenId,
        KineticTokens.stitchAccessScannerScreenId,
      );
      expect(AccessScannerScreen.stitchScreenTitle, 'Access Scanner');
    });

    test('sync member roster use case returns count', () async {
      final repository = _MockMemberRosterRepository();
      when(
        () => repository.syncRoster(tenantId: any(named: 'tenantId')),
      ).thenAnswer((_) async => 3);

      final useCase = SyncMemberRosterUseCase(repository);
      final count = await useCase(tenantId: 'tenant-1');

      expect(count, 3);
      verify(() => repository.syncRoster(tenantId: 'tenant-1')).called(1);
    });

    test('member roster entry maps cloud fields', () {
      final entry = MemberRosterEntry(
        id: 'athlete-1',
        fullName: 'Sara Al-Fares',
        avatarUrl: 'https://example.com/a.png',
        powerScore: 780,
        cryptoSalt: 'salt-abc',
        createdAt: DateTime.utc(2026, 1, 1),
      );
      expect(entry.fullName, 'Sara Al-Fares');
      expect(entry.powerScore, 780);
    });

    test('policy failure exposes localized key', () {
      const failure = MemberRosterPolicyFailure();
      expect(failure.messageKey, 'access_scanner.roster.error.policy');
    });

    test('empty failure exposes seed guidance key', () {
      const failure = MemberRosterEmptyFailure();
      expect(failure.messageKey, 'access_scanner.roster.error.empty');
    });
  });

  group('AccessScannerCubit roster sync', () {
    late _MockMemberRosterRepository repository;
    late _MockProcessQrScan processQrScan;
    late SyncMemberRosterUseCase syncUseCase;
    var online = true;

    AccessScannerCubit buildCubit() {
      return AccessScannerCubit(
        processQrScan: processQrScan,
        syncMemberRoster: syncUseCase,
        memberRosterRepository: repository,
        tenantId: 'tenant-1',
        isOnline: () => online,
      );
    }

    Future<List<AccessScannerState>> collect(
      AccessScannerCubit cubit,
      Future<void> Function() act,
    ) async {
      final states = <AccessScannerState>[];
      final sub = cubit.stream.listen(states.add);
      await act();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await sub.cancel();
      return states;
    }

    setUp(() {
      repository = _MockMemberRosterRepository();
      processQrScan = _MockProcessQrScan();
      syncUseCase = SyncMemberRosterUseCase(repository);
      online = true;
      when(
        () => repository.countCachedMembers(tenantId: any(named: 'tenantId')),
      ).thenAnswer((_) async => 0);
    });

    test('syncRoster emits synced count when athletes returned', () async {
      when(
        () => repository.syncRoster(tenantId: any(named: 'tenantId')),
      ).thenAnswer((_) async => 4);

      final cubit = buildCubit();
      final states = await collect(cubit, cubit.syncRoster);

      expect(states.first.rosterStatus, AccessScannerRosterStatus.syncing);
      expect(states.last.rosterStatus, AccessScannerRosterStatus.synced);
      expect(states.last.rosterCount, 4);
      await cubit.close();
    });

    test('syncRoster emits empty error when cloud returns 0 members', () async {
      when(
        () => repository.syncRoster(tenantId: any(named: 'tenantId')),
      ).thenAnswer((_) async => 0);

      final cubit = buildCubit();
      final states = await collect(cubit, cubit.syncRoster);

      expect(states.last.rosterStatus, AccessScannerRosterStatus.failed);
      expect(states.last.rosterErrorKey, 'access_scanner.roster.error.empty');
      expect(states.last.rosterCount, 0);
      await cubit.close();
    });

    test('syncRoster surfaces policy failure with retryable key', () async {
      when(
        () => repository.syncRoster(tenantId: any(named: 'tenantId')),
      ).thenThrow(const MemberRosterPolicyFailure());

      final cubit = buildCubit();
      final states = await collect(cubit, cubit.syncRoster);

      expect(states.last.rosterStatus, AccessScannerRosterStatus.failed);
      expect(states.last.rosterErrorKey, 'access_scanner.roster.error.policy');
      await cubit.close();
    });

    test(
      'onScannerOpened offline refreshes local count without remote sync',
      () async {
        online = false;
        when(
          () => repository.countCachedMembers(tenantId: any(named: 'tenantId')),
        ).thenAnswer((_) async => 2);

        final cubit = buildCubit();
        final states = await collect(cubit, cubit.onScannerOpened);

        expect(states.last.rosterCount, 2);
        expect(states.last.rosterStatus, AccessScannerRosterStatus.synced);
        verifyNever(
          () => repository.syncRoster(tenantId: any(named: 'tenantId')),
        );
        await cubit.close();
      },
    );

    test('onScannerOpened online syncs after local count', () async {
      when(
        () => repository.countCachedMembers(tenantId: any(named: 'tenantId')),
      ).thenAnswer((_) async => 0);
      when(
        () => repository.syncRoster(tenantId: any(named: 'tenantId')),
      ).thenAnswer((_) async => 1);

      final cubit = buildCubit();
      final states = await collect(cubit, cubit.onScannerOpened);

      expect(
        states.map((s) => s.rosterStatus),
        containsAll([
          AccessScannerRosterStatus.syncing,
          AccessScannerRosterStatus.synced,
        ]),
      );
      expect(states.last.rosterCount, 1);
      verify(
        () => repository.syncRoster(tenantId: 'tenant-1'),
      ).called(1);
      await cubit.close();
    });

    test('markCameraReady emits once and is idempotent', () async {
      final cubit = buildCubit();
      final states = await collect(cubit, () async {
        cubit.markCameraReady();
        cubit.markCameraReady();
      });

      expect(states, hasLength(1));
      expect(states.single.cameraReady, isTrue);
      await cubit.close();
    });

    testWidgets(
      'post-frame scheduling avoids setState during build',
      (tester) async {
        var useManual = false;

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: StatefulBuilder(
              builder: (context, setState) {
                // Mirrors AccessScannerScreen camera fallback: schedule after
                // frame instead of setState inside MobileScanner errorBuilder.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() => useManual = true);
                });
                return Text(useManual ? 'manual' : 'camera');
              },
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(find.text('camera'), findsOneWidget);

        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.text('manual'), findsOneWidget);
      },
    );
  });

  group('FEAT-01 AC1 — offline session restore', () {
    const adminProfile = EmployeeProfile(
      id: 'emp-1',
      tenantId: 'tenant-gym-1',
      userId: 'user-admin-1',
      name: 'Sara Reception',
      role: 'Receptionist',
    );

    late _MockAuthRepository repository;

    setUpAll(() {
      registerFallbackValue(_FakeSession());
    });

    setUp(() {
      repository = _MockAuthRepository();
    });

    Future<List<AuthState>> _collect(AuthBloc bloc) async {
      final states = <AuthState>[];
      final sub = bloc.stream.listen(states.add);
      bloc.add(const AuthStarted());
      final deadline = DateTime.now().add(const Duration(seconds: 2));
      while (states.length < 2 && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      await sub.cancel();
      return states;
    }

    test('AuthStarted without session restores cached portal profile', () async {
      when(() => repository.currentSession).thenReturn(null);
      when(() => repository.readCachedProfile()).thenAnswer((_) async => adminProfile);

      final bloc = AuthBloc(authRepository: repository);
      final states = await _collect(bloc);

      expect(states.last, isA<AuthAuthenticated>());
      final auth = states.last as AuthAuthenticated;
      expect(auth.profile, adminProfile);
      expect(auth.restoredFromCache, isTrue);
      await bloc.close();
    });

    test(
      'AuthStarted with session but resolve failure falls back to cache',
      () async {
        when(() => repository.currentSession).thenReturn(_FakeSession());
        when(() => repository.resolveEmployeeProfile()).thenThrow(
          Exception('network'),
        );
        when(
          () => repository.readCachedProfile(),
        ).thenAnswer((_) async => adminProfile);

        final bloc = AuthBloc(authRepository: repository);
        final states = await _collect(bloc);

        expect(states.last, isA<AuthAuthenticated>());
        expect((states.last as AuthAuthenticated).restoredFromCache, isTrue);
        await bloc.close();
      },
    );
  });
}
