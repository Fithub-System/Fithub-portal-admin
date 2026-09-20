import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/kinetic_tokens.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/widgets/stitch_auth_snackbar.dart';

/// FEAT-96 founder register — Stitch `4ca7b76eff8742ffb57fd394709c4a63`.
class GymRegisterPage extends StatefulWidget {
  const GymRegisterPage({super.key});

  static const String stitchScreenIdEn = '4ca7b76eff8742ffb57fd394709c4a63';
  static const String stitchScreenIdAr = '69cda5c26fb44c6680f6eafb41b5743a';

  @override
  State<GymRegisterPage> createState() => _GymRegisterPageState();
}

class _GymRegisterPageState extends State<GymRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _trading = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _trading.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthBloc>().add(
      AuthRegisterSubmitted(
        email: _email.text,
        password: _password.text,
        tradingName: _trading.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        final raw = switch (state) {
          AuthRegisterForm(:final message, submitting: false) => message,
          AuthUnauthenticated(:final message) => message,
          _ => null,
        };
        if (raw == null) return;
        StitchAuthSnackbar.show(
          context,
          raw.startsWith('auth.') || raw.startsWith('onboarding.')
              ? raw.tr()
              : raw,
        );
      },
      builder: (context, state) {
        final busy = state is AuthRegisterForm && state.submitting;
        return Scaffold(
          backgroundColor: KineticTokens.deepCharcoal,
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Text(
                        'onboarding.register.title'.tr(),
                        style: const TextStyle(
                          color: KineticTokens.pureWhite,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'onboarding.register.subtitle'.tr(),
                        style: const TextStyle(color: KineticTokens.zincGray),
                      ),
                      TextFormField(
                        controller: _trading,
                        style: const TextStyle(color: KineticTokens.pureWhite),
                        decoration: InputDecoration(
                          labelText: 'onboarding.register.trading'.tr(),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'onboarding.register.required'.tr()
                            : null,
                      ),
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: KineticTokens.pureWhite),
                        decoration: InputDecoration(
                          labelText: 'onboarding.register.email'.tr(),
                        ),
                        validator: (v) => (v == null || !v.contains('@'))
                            ? 'onboarding.register.required'.tr()
                            : null,
                      ),
                      TextFormField(
                        controller: _password,
                        obscureText: true,
                        style: const TextStyle(color: KineticTokens.pureWhite),
                        decoration: InputDecoration(
                          labelText: 'onboarding.register.password'.tr(),
                        ),
                        validator: (v) => (v == null || v.length < 8)
                            ? 'onboarding.register.password_short'.tr()
                            : null,
                      ),
                      TextFormField(
                        controller: _confirm,
                        obscureText: true,
                        style: const TextStyle(color: KineticTokens.pureWhite),
                        decoration: InputDecoration(
                          labelText: 'onboarding.register.confirm'.tr(),
                        ),
                        validator: (v) => v != _password.text
                            ? 'onboarding.register.mismatch'.tr()
                            : null,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: KineticTokens.electricLime,
                          foregroundColor: KineticTokens.deepCharcoal,
                          minimumSize: const Size.fromHeight(52),
                        ),
                        onPressed: busy ? null : _submit,
                        child: busy
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text('onboarding.register.cta'.tr()),
                      ),
                      TextButton(
                        onPressed: busy
                            ? null
                            : () => context.read<AuthBloc>().add(
                                const AuthLoginRequested(),
                              ),
                        child: Text('onboarding.register.have_account'.tr()),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class GymCheckEmailPage extends StatelessWidget {
  const GymCheckEmailPage({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'onboarding.register.check_email'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: KineticTokens.pureWhite,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                email,
                style: const TextStyle(color: KineticTokens.electricLime),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () =>
                    context.read<AuthBloc>().add(const AuthSignOutRequested()),
                child: Text('onboarding.register.back_login'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
