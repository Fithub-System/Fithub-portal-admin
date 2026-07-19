import 'package:flutter_test/flutter_test.dart';
import 'package:fithub_portal_admin/features/auth/domain/auth_failure.dart';
import 'package:fithub_portal_admin/features/auth/domain/entities/employee_profile.dart';
import 'package:fithub_portal_admin/features/auth/domain/repositories/auth_repository.dart';
import 'package:fithub_portal_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

class _MockAuthRepository extends Mock implements AuthRepository {}

class _FakeSession extends Fake implements Session {}

void main() {
  late _MockAuthRepository repository;

  const adminProfile = EmployeeProfile(
    id: 'emp-1',
    tenantId: 'tenant-gym-1',
    userId: 'user-admin-1',
    name: 'Sara Reception',
    role: 'Receptionist',
  );

  setUpAll(() {
    registerFallbackValue(_FakeSession());
  });

  setUp(() {
    repository = _MockAuthRepository();
  });

  Future<List<AuthState>> _collect(
    AuthBloc bloc,
    AuthEvent event, {
    int count = 2,
  }) async {
    final states = <AuthState>[];
    final sub = bloc.stream.listen(states.add);
    bloc.add(event);
    await Future<void>.delayed(Duration.zero);
    // Wait until we have enough emissions or timeout.
    final deadline = DateTime.now().add(const Duration(seconds: 2));
    while (states.length < count && DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    await sub.cancel();
    return states;
  }

  group('AC-A1 — valid employee sign-in resolves tenant + role + home', () {
    test(
      'emits loading then authenticated with tenant_id + portal role',
      () async {
        when(
          () => repository.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => adminProfile);

        final bloc = AuthBloc(authRepository: repository);
        final states = await _collect(
          bloc,
          const AuthSignInSubmitted(email: 'sara@gym.com', password: 'secret'),
        );

        expect(states, [
          const AuthLoading(),
          const AuthAuthenticated(adminProfile),
        ]);
        expect(adminProfile.role, 'Receptionist');
        expect(adminProfile.tenantId, 'tenant-gym-1');
        verify(
          () => repository.signInWithPassword(
            email: 'sara@gym.com',
            password: 'secret',
          ),
        ).called(1);
        await bloc.close();
      },
    );
  });

  group('AC-A2 — Auth ok but missing employees row denied', () {
    test(
      'emits unauthenticated with profile-missing message; not Authenticated',
      () async {
        when(
          () => repository.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(const EmployeeProfileMissingFailure());

        final bloc = AuthBloc(authRepository: repository);
        final states = await _collect(
          bloc,
          const AuthSignInSubmitted(
            email: 'orphan@gym.com',
            password: 'secret',
          ),
        );

        expect(states.first, const AuthLoading());
        expect(states.last, isA<AuthUnauthenticated>());
        expect(
          (states.last as AuthUnauthenticated).message,
          'auth.error.employee_profile_missing',
        );
        expect(states.whereType<AuthAuthenticated>(), isEmpty);
        await bloc.close();
      },
    );
  });

  group('AC-A3 — invalid credentials show Stitch error path (no home)', () {
    test('emits unauthenticated with invalid-credentials message', () async {
      when(
        () => repository.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const InvalidCredentialsFailure());

      final bloc = AuthBloc(authRepository: repository);
      final states = await _collect(
        bloc,
        const AuthSignInSubmitted(email: 'bad@gym.com', password: 'wrong'),
      );

      expect(states.first, const AuthLoading());
      expect(states.last, isA<AuthUnauthenticated>());
      expect(
        (states.last as AuthUnauthenticated).message,
        'auth.error.invalid_credentials',
      );
      expect(states.whereType<AuthAuthenticated>(), isEmpty);
      await bloc.close();
    });
  });

  group('AC-D1 — cold start with persisted session skips login', () {
    test(
      'AuthStarted with session resolves employee → Authenticated',
      () async {
        when(() => repository.currentSession).thenReturn(_FakeSession());
        when(
          () => repository.resolveEmployeeProfile(),
        ).thenAnswer((_) async => adminProfile);

        final bloc = AuthBloc(authRepository: repository);
        final states = await _collect(bloc, const AuthStarted());

        expect(states, [
          const AuthLoading(),
          const AuthAuthenticated(adminProfile),
        ]);
        verify(() => repository.resolveEmployeeProfile()).called(1);
        await bloc.close();
      },
    );

    test(
      'AuthStarted without session → Unauthenticated (login shown)',
      () async {
        when(() => repository.currentSession).thenReturn(null);

        final bloc = AuthBloc(authRepository: repository);
        final states = await _collect(bloc, const AuthStarted());

        expect(states, [const AuthLoading(), const AuthUnauthenticated()]);
        await bloc.close();
      },
    );
  });
}
