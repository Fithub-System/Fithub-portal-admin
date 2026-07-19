import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fithub_portal_admin/config/router/app_router.dart';
import 'package:fithub_portal_admin/config/theme/app_theme.dart';
import 'package:fithub_portal_admin/core/network/locale_code_holder.dart';
import 'package:fithub_portal_admin/core/network/supabase_locale_headers.dart';
import 'package:fithub_portal_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fithub_portal_admin/injection_container.dart';

/// Root widget for Pulse Gym Admin Portal (fithub_portal_admin).
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // AC-I7: refresh Accept-Language whenever EasyLocalization locale changes.
    LocaleCodeHolder.update(context.locale.languageCode);
    SupabaseLocaleHeaders.apply(context.locale.languageCode);

    return BlocProvider(
      create: (_) =>
          AuthBloc(authRepository: InjectionContainer.authRepository)
            ..add(const AuthStarted()),
      child: MaterialApp(
        title: 'app.title'.tr(),
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkFor(context.locale),
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
        navigatorKey: AppRouter.navigatorKey,
        home: AppRouter.authGate(),
      ),
    );
  }
}
