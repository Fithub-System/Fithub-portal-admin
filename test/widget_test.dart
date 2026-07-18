import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fithub_portal_admin/config/theme/app_theme.dart';
import 'package:fithub_portal_admin/features/auth/domain/entities/employee_profile.dart';
import 'package:fithub_portal_admin/features/auth/domain/repositories/auth_repository.dart';
import 'package:fithub_portal_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fithub_portal_admin/features/auth/presentation/pages/login_page.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  testWidgets('cold start without session shows Stitch Gym Connect brand',
      (tester) async {
    final repository = _MockAuthRepository();
    when(() => repository.currentSession).thenReturn(null);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: BlocProvider(
          create: (_) => AuthBloc(authRepository: repository)
            ..add(const AuthStarted()),
          child: const LoginPage(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Gym Connect'), findsOneWidget);
    expect(find.text('COMMAND CENTER LOGIN'), findsOneWidget);
    expect(find.text('INITIALIZE SESSION'), findsOneWidget);
  });
}
