import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import 'package:fithub_portal_admin/config/theme/kinetic_tokens.dart';
import 'package:fithub_portal_admin/features/access_scanner/domain/entities/member_roster_entry.dart';
import 'package:fithub_portal_admin/features/access_scanner/domain/member_roster_failure.dart';
import 'package:fithub_portal_admin/features/access_scanner/domain/repositories/member_roster_repository.dart';
import 'package:fithub_portal_admin/features/access_scanner/domain/use_cases/sync_member_roster_use_case.dart';
import 'package:fithub_portal_admin/features/access_scanner/presentation/screens/access_scanner_screen.dart';
import 'package:fithub_portal_admin/features/auth/domain/entities/employee_profile.dart';
import 'package:fithub_portal_admin/features/auth/domain/repositories/auth_repository.dart';
import 'package:fithub_portal_admin/features/auth/presentation/bloc/auth_bloc.dart';

class _MockMemberRosterRepository extends Mock
    implements MemberRosterRepository {}

class _MockAuthRepository extends Mock implements AuthRepository {}

class _FakeSession extends Fake implements Session {}

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
