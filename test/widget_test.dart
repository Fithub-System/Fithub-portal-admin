import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fithub_portal_admin/core/i18n/app_locales.dart';
import 'package:fithub_portal_admin/features/auth/domain/repositories/auth_repository.dart';
import 'package:fithub_portal_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fithub_portal_admin/features/auth/presentation/pages/login_page.dart';
import 'package:mocktail/mocktail.dart';

import 'support/localized_pump.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  testWidgets('cold start without session shows Stitch Gym Connect brand', (
    tester,
  ) async {
    final repository = _MockAuthRepository();
    when(() => repository.currentSession).thenReturn(null);
    when(() => repository.readCachedProfile()).thenAnswer((_) async => null);

    await pumpLocalizedApp(
      tester,
      BlocProvider(
        create: (_) =>
            AuthBloc(authRepository: repository)..add(const AuthStarted()),
        child: const LoginPage(),
      ),
      waitFor: find.text('GYM CONNECT'),
    );

    expect(find.text('GYM CONNECT'), findsOneWidget);
    expect(find.text('COMMAND CENTER LOGIN'), findsOneWidget);
    expect(find.text('INITIALIZE SESSION'), findsOneWidget);
    expect(find.text('EN'), findsOneWidget);
    expect(find.text('AR'), findsOneWidget);
  });

  testWidgets('Arabic start locale renders translated login without crash', (
    tester,
  ) async {
    final repository = _MockAuthRepository();
    when(() => repository.currentSession).thenReturn(null);
    when(() => repository.readCachedProfile()).thenAnswer((_) async => null);

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
    expect(find.text('بدء الجلسة'), findsOneWidget);
    expect(find.text('EN'), findsOneWidget);
    expect(find.text('AR'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
