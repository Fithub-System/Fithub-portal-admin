import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fithub_portal_admin/config/router/app_router.dart';
import 'package:fithub_portal_admin/core/network/supabase_config.dart';
import 'package:fithub_portal_admin/features/auth/domain/auth_failure.dart';
import 'package:fithub_portal_admin/features/auth/domain/entities/employee_profile.dart';
import 'package:fithub_portal_admin/features/auth/domain/repositories/auth_repository.dart';
import 'package:fithub_portal_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fithub_portal_admin/features/auth/presentation/pages/login_page.dart';
import 'package:fithub_portal_admin/features/gym_onboarding/data/gym_onboarding_remote.dart';
import 'package:fithub_portal_admin/features/gym_onboarding/presentation/gym_onboarding_cubit.dart';
import 'package:fithub_portal_admin/features/gym_onboarding/presentation/screens/gym_onboarding_wizard_page.dart';
import 'package:fithub_portal_admin/features/gym_onboarding/presentation/screens/gym_register_page.dart';
import 'package:mocktail/mocktail.dart';

import 'support/localized_pump.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  const draftAdmin = EmployeeProfile(
    id: 'emp-1',
    tenantId: 'gym-1',
    userId: 'user-1',
    name: 'Founder',
    role: 'Admin',
    onboardingStatus: 'draft',
  );

  const activeAdmin = EmployeeProfile(
    id: 'emp-2',
    tenantId: 'gym-2',
    userId: 'user-2',
    name: 'Live Admin',
    role: 'Admin',
  );

  late _MockAuthRepository repository;

  setUp(() {
    repository = _MockAuthRepository();
    when(() => repository.currentSession).thenReturn(null);
    when(() => repository.readCachedProfile()).thenAnswer((_) async => null);
  });

  test('Stitch screen ids match FEAT-96 inventory', () {
    expect(
      GymRegisterPage.stitchScreenIdEn,
      '4ca7b76eff8742ffb57fd394709c4a63',
    );
    expect(
      GymOnboardingWizardPage.stitchStep1En,
      '89e695b4c4bc4a8d8319bcf9afcc8ac5',
    );
    expect(
      GymOnboardingWizardPage.stitchStep5En,
      'a5827af544e540b7a7890da089327b2a',
    );
    expect(
      GymOnboardingWizardPage.stitchProfileEn,
      '28a6e5e325164b70a9a139f4599832c4',
    );
    expect(GymOnboardingWizardPage.formMaxWidth, 720);
  });

  test(
    'founder confirm lands on the Vercel Portal host, not fitness-hub.app',
    () {
      expect(
        SupabaseConfig.emailRedirectTo,
        'https://fithub-portal-admin.vercel.app',
      );
      expect(
        SupabaseConfig.emailRedirectTo.contains('fitness-hub.app'),
        isFalse,
      );
    },
  );

  test('only draft Admin needs the wizard; live gyms stay on the shell', () {
    expect(draftAdmin.needsOnboarding, isTrue);
    expect(activeAdmin.needsOnboarding, isFalse);
    expect(
      const EmployeeProfile(
        id: 'r',
        tenantId: 'g',
        userId: 'u',
        name: 'Desk',
        role: 'Receptionist',
        onboardingStatus: 'draft',
      ).needsOnboarding,
      isFalse,
    );
  });

  test(
    'founder register with session lands Authenticated (wizard gate)',
    () async {
      when(
        () => repository.signUpGymFounder(
          email: any(named: 'email'),
          password: any(named: 'password'),
          tradingName: any(named: 'tradingName'),
        ),
      ).thenAnswer((_) async => draftAdmin);

      final bloc = AuthBloc(authRepository: repository);
      bloc.add(
        const AuthRegisterSubmitted(
          email: 'owner@gym.com',
          password: 'secret123',
          tradingName: 'Pulse Maadi',
        ),
      );
      await expectLater(
        bloc.stream,
        emitsInOrder([
          const AuthRegisterForm(submitting: true),
          const AuthAuthenticated(draftAdmin),
        ]),
      );
      expect(const AuthAuthenticated(draftAdmin).showOnboardingWizard, isTrue);
      await bloc.close();
    },
  );

  test('founder register without session waits for email confirm', () async {
    when(
      () => repository.signUpGymFounder(
        email: any(named: 'email'),
        password: any(named: 'password'),
        tradingName: any(named: 'tradingName'),
      ),
    ).thenAnswer((_) async => null);

    final bloc = AuthBloc(authRepository: repository);
    bloc.add(
      const AuthRegisterSubmitted(
        email: 'owner@gym.com',
        password: 'secret123',
        tradingName: 'Pulse Maadi',
      ),
    );
    await expectLater(
      bloc.stream,
      emitsInOrder([
        const AuthRegisterForm(submitting: true),
        const AuthAwaitingEmailConfirmation('owner@gym.com'),
      ]),
    );
    await bloc.close();
  });

  test('duplicate email surfaces auth.error.email_taken', () async {
    when(
      () => repository.signUpGymFounder(
        email: any(named: 'email'),
        password: any(named: 'password'),
        tradingName: any(named: 'tradingName'),
      ),
    ).thenThrow(const InvalidCredentialsFailure('auth.error.email_taken'));

    final bloc = AuthBloc(authRepository: repository);
    bloc.add(
      const AuthRegisterSubmitted(
        email: 'dup@gym.com',
        password: 'secret123',
        tradingName: 'Dup',
      ),
    );
    await expectLater(
      bloc.stream,
      emitsInOrder([
        const AuthRegisterForm(submitting: true),
        const AuthRegisterForm(message: 'auth.error.email_taken'),
      ]),
    );
    await bloc.close();
  });

  test('Finish later defers wizard; resume restores it', () async {
    when(
      () => repository.readCachedProfile(),
    ).thenAnswer((_) async => draftAdmin);

    final bloc = AuthBloc(authRepository: repository);
    bloc.add(const AuthStarted());
    await expectLater(
      bloc.stream,
      emitsInOrder([
        const AuthLoading(),
        const AuthAuthenticated(draftAdmin, restoredFromCache: true),
      ]),
    );

    bloc.add(const AuthOnboardingDeferred());
    await expectLater(
      bloc.stream,
      emits(
        const AuthAuthenticated(
          draftAdmin,
          restoredFromCache: true,
          deferOnboarding: true,
        ),
      ),
    );

    bloc.add(const AuthOnboardingResumeRequested());
    await expectLater(
      bloc.stream,
      emits(const AuthAuthenticated(draftAdmin, restoredFromCache: true)),
    );
    await bloc.close();
  });

  test(
    'Register CTA opens AuthRegisterForm without AuthLoading splash',
    () async {
      final bloc = AuthBloc(authRepository: repository);
      bloc.add(const AuthRegisterRequested());
      await expectLater(bloc.stream, emits(const AuthRegisterForm()));
      bloc.add(const AuthLoginRequested());
      await expectLater(bloc.stream, emits(const AuthUnauthenticated()));
      await bloc.close();
    },
  );

  testWidgets('login Register CTA is present and is not Coming soon', (
    tester,
  ) async {
    await pumpLocalizedApp(
      tester,
      BlocProvider(
        create: (_) =>
            AuthBloc(authRepository: repository)..add(const AuthStarted()),
        child: const LoginPage(),
      ),
      waitFor: find.byKey(const Key('login-cta-register')),
    );

    expect(find.byKey(const Key('login-cta-initialize')), findsOneWidget);
    expect(find.byKey(const Key('login-cta-register')), findsOneWidget);
    expect(find.text('Register your gym'), findsOneWidget);
    expect(find.textContaining('Coming soon'), findsNothing);
  });

  testWidgets('cold start is login; register appears only after CTA tap', (
    tester,
  ) async {
    await pumpLocalizedApp(
      tester,
      BlocProvider(
        create: (_) =>
            AuthBloc(authRepository: repository)..add(const AuthStarted()),
        child: AppRouter.authGate(),
      ),
      waitFor: find.byKey(const Key('login-cta-register')),
    );

    expect(find.byKey(const Key('login-cta-initialize')), findsOneWidget);
    expect(find.text('Create gym account'), findsNothing);

    await tester.tap(find.byKey(const Key('login-cta-register')));
    await tester.pumpAndSettle();

    expect(find.text('Create gym account'), findsOneWidget);
    expect(find.byKey(const Key('login-cta-initialize')), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  test('new gym branch form has no static sandbox defaults', () {
    const empty = GymOnboardingState(loading: false);
    expect(empty.lat, isNull);
    expect(empty.lng, isNull);
    expect(empty.capacity, isNull);
    expect(empty.amenityTags, isEmpty);
    expect(empty.hoursOpen, isEmpty);
    expect(empty.hoursClose, isEmpty);
    expect(empty.photoUrl, isEmpty);
    expect(empty.planName, isEmpty);
    expect(empty.planDays, isNull);
    expect(empty.planPriceEgp, isNull);
    expect(GymOnboardingCubit.hoursFrom(open: '', close: ''), isEmpty);
    expect(
      GymOnboardingCubit.isLivePhoto(GymOnboardingRemote.placeholderPhoto),
      isFalse,
    );
  });

  testWidgets('Gym Profile stepper is tappable so Admin can edit each step', (
    tester,
  ) async {
    await pumpLocalizedApp(
      tester,
      BlocProvider(
        create: (_) =>
            GymOnboardingCubit(remote: _FakeOnboardingRemote())..load(),
        child: GymOnboardingWizardPage(onClose: () {}),
      ),
      waitFor: find.text('Brand & legal'),
    );

    expect(find.text('Pulse Maadi'), findsWidgets);
    expect(find.text('Create gym account'), findsNothing);

    await tester.tap(find.byKey(const Key('gym-profile-step-1')));
    await tester.pumpAndSettle();
    expect(find.text('Branch & facilities'), findsOneWidget);
    expect(find.text('Latitude'), findsOneWidget);
    expect(find.text('30.0444'), findsNothing);

    await tester.tap(find.byKey(const Key('gym-profile-step-4')));
    await tester.pumpAndSettle();
    expect(find.text('Readiness & publish'), findsOneWidget);
  });
}

class _FakeOnboardingRemote extends Fake implements GymOnboardingRemote {
  @override
  Future<GymOnboardingSnapshot> load() async {
    return GymOnboardingSnapshot(
      gym: <String, dynamic>{
        'name': 'Pulse Maadi',
        'trading_name': 'Pulse Maadi',
        'contact_name': 'Founder',
      },
      branches: const [],
      score: 0,
      canPublish: false,
      checks: const [],
    );
  }
}
