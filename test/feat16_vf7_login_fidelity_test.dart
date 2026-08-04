import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fithub_portal_admin/config/theme/app_colors.dart';
import 'package:fithub_portal_admin/core/i18n/app_locales.dart';
import 'package:fithub_portal_admin/features/auth/domain/repositories/auth_repository.dart';
import 'package:fithub_portal_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fithub_portal_admin/features/auth/presentation/pages/login_page.dart';
import 'package:mocktail/mocktail.dart';

import 'support/localized_pump.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;

  setUp(() {
    repository = _MockAuthRepository();
    when(() => repository.currentSession).thenReturn(null);
    when(() => repository.readCachedProfile()).thenAnswer((_) async => null);
  });

  group('FEAT-16 VF7 login citations', () {
    test('cites locked Web Admin Login EN + AR twin ids', () {
      expect(
        LoginPage.stitchScreenIdEn,
        'c12b687f1538452ebaf8d0adb89a9489',
      );
      expect(
        LoginPage.stitchScreenIdAr,
        '0f33f7463ca543c7b85bcb8637249f65',
      );
    });

    test('Kinetic login tokens match Stitch namedColors', () {
      expect(AppColors.background.toARGB32(), 0xFF131313);
      expect(AppColors.surfaceContainerLow.toARGB32(), 0xFF1C1B1B);
      expect(AppColors.primaryContainer.toARGB32(), 0xFFC3F400);
      expect(AppColors.onPrimaryContainer.toARGB32(), 0xFF556D00);
      expect(AppColors.secondary.toARGB32(), 0xFFADC7FF);
    });
  });

  group('FEAT-16 VF7 login regions', () {
    testWidgets('ships full artboard chrome — never blank shells', (
      tester,
    ) async {
      await pumpLocalizedApp(
        tester,
        BlocProvider(
          create: (_) =>
              AuthBloc(authRepository: repository)..add(const AuthStarted()),
          child: const LoginPage(),
        ),
        waitFor: find.byKey(const Key('login-cta-initialize')),
      );

      expect(find.byKey(const Key('login-page')), findsOneWidget);
      expect(find.byKey(const Key('login-brand')), findsOneWidget);
      expect(find.text('GYM CONNECT'), findsOneWidget);
      expect(find.text('COMMAND CENTER LOGIN'), findsOneWidget);
      expect(find.byKey(const Key('login-card')), findsOneWidget);
      expect(find.byKey(const Key('login-card-kinetic-edge')), findsOneWidget);
      expect(find.text('CREDENTIAL IDENTIFIER'), findsOneWidget);
      expect(find.text('Email or Username'), findsOneWidget);
      expect(find.text('ACCESS KEY'), findsOneWidget);
      expect(find.text('Recover Key'), findsOneWidget);
      expect(find.text('INITIALIZE SESSION'), findsOneWidget);
      expect(find.textContaining('OR VIA SOCIAL'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Continue with Apple'), findsOneWidget);
      expect(find.text('Privacy Protocol'), findsOneWidget);
      expect(find.text('Terms of Access'), findsOneWidget);
      expect(
        find.textContaining('KINETIC PERFORMANCE SYSTEMS'),
        findsOneWidget,
      );
      expect(find.text('—'), findsNothing);
      expect(find.textContaining('Coming soon'), findsNothing);
    });

    testWidgets('AR twin copy + RTL regions present', (tester) async {
      await pumpLocalizedApp(
        tester,
        BlocProvider(
          create: (_) =>
              AuthBloc(authRepository: repository)..add(const AuthStarted()),
          child: const LoginPage(),
        ),
        locale: AppLocales.ar,
        waitFor: find.text('بدء الجلسة'),
      );

      expect(find.text('GYM CONNECT'), findsOneWidget);
      expect(find.text('مركز قيادة تسجيل الدخول'), findsOneWidget);
      expect(find.text('معرف الاعتماد'), findsOneWidget);
      expect(find.text('استعادة المفتاح'), findsOneWidget);
      expect(find.text('أو عبر الرابط الاجتماعي'), findsOneWidget);
      expect(find.text('المتابعة باستخدام Google'), findsOneWidget);
      expect(find.text('المتابعة باستخدام Apple'), findsOneWidget);
      expect(find.text('بروتوكول الخصوصية'), findsOneWidget);
      expect(find.byKey(const Key('login-cta-initialize')), findsOneWidget);
      expect(find.text('—'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('FEAT-03 locale chips + FEAT-02 form keys preserved', (
      tester,
    ) async {
      await pumpLocalizedApp(
        tester,
        BlocProvider(
          create: (_) =>
              AuthBloc(authRepository: repository)..add(const AuthStarted()),
          child: const LoginPage(),
        ),
        waitFor: find.byKey(const Key('login-locale-toggle')),
      );

      expect(find.byKey(const Key('login-locale-toggle')), findsOneWidget);
      expect(find.text('EN'), findsOneWidget);
      expect(find.text('AR'), findsOneWidget);
      expect(find.byKey(const Key('login-credential-field')), findsOneWidget);
      expect(find.byKey(const Key('login-access-key-field')), findsOneWidget);
      expect(find.byKey(const Key('login-recover-key')), findsOneWidget);
      expect(find.byKey(const Key('login-social-google')), findsOneWidget);
      expect(find.byKey(const Key('login-social-apple')), findsOneWidget);
    });
  });
}
