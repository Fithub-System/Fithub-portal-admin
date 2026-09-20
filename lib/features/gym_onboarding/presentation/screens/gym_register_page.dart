import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/kinetic_tokens.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/widgets/stitch_auth_snackbar.dart';
import '../widgets/stitch_kinetic_chrome.dart';

/// FEAT-96 founder register — Stitch `4ca7b76eff8742ffb57fd394709c4a63`.
class GymRegisterPage extends StatefulWidget {
  const GymRegisterPage({super.key, this.onBackToLogin});

  /// When opened from login, returns to that screen instead of a root route.
  final VoidCallback? onBackToLogin;

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
  var _attested = false;

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
    if (!_attested) {
      StitchAuthSnackbar.show(
        context,
        'onboarding.register.attest_required'.tr(),
      );
      return;
    }
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
          body: Column(
            children: [
              const StitchPulseTopBar(),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                    child: StitchKineticCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            StitchStageBadge(
                              label: 'onboarding.register.eyebrow'.tr(),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'onboarding.register.title'.tr(),
                              style: const TextStyle(
                                color: KineticTokens.pureWhite,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                height: 1.05,
                                letterSpacing: -0.6,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'onboarding.register.subtitle'.tr(),
                              style: const TextStyle(
                                color: KineticTokens.zincGray,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 24),
                            StitchFilledField(
                              key: const Key('gym-register-trading'),
                              controller: _trading,
                              label: 'onboarding.register.trading'.tr(),
                              hint: 'onboarding.register.trading_hint'.tr(),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'onboarding.register.required'.tr()
                                  : null,
                            ),
                            StitchFilledField(
                              key: const Key('gym-register-email'),
                              controller: _email,
                              label: 'onboarding.register.email'.tr(),
                              hint: 'onboarding.register.email_hint'.tr(),
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) => (v == null || !v.contains('@'))
                                  ? 'onboarding.register.required'.tr()
                                  : null,
                            ),
                            StitchFilledField(
                              controller: _password,
                              label: 'onboarding.register.password'.tr(),
                              obscure: true,
                              validator: (v) => (v == null || v.length < 8)
                                  ? 'onboarding.register.password_short'.tr()
                                  : null,
                            ),
                            StitchFilledField(
                              controller: _confirm,
                              label: 'onboarding.register.confirm'.tr(),
                              obscure: true,
                              validator: (v) => v != _password.text
                                  ? 'onboarding.register.mismatch'.tr()
                                  : null,
                            ),
                            const SizedBox(height: 4),
                            InkWell(
                              onTap: () =>
                                  setState(() => _attested = !_attested),
                              child: Row(
                                children: [
                                  Icon(
                                    _attested
                                        ? Icons.check_box
                                        : Icons.check_box_outline_blank,
                                    color: KineticTokens.electricLime,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'onboarding.register.attest'.tr(),
                                      style: const TextStyle(
                                        color: KineticTokens.onSurface,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            StitchLimeCta(
                              label: 'onboarding.register.cta'.tr(),
                              busy: busy,
                              onTap: _submit,
                            ),
                            const SizedBox(height: 16),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: KineticTokens.deepCharcoal,
                                borderRadius: BorderRadius.circular(10),
                                border: const Border(
                                  left: BorderSide(
                                    color: KineticTokens.electricLime,
                                    width: 3,
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.campaign_outlined,
                                      color: KineticTokens.electricLime,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'onboarding.register.staff_note'.tr(),
                                        style: const TextStyle(
                                          color: KineticTokens.zincGray,
                                          fontSize: 12,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'onboarding.register.verification'.tr(),
                              style: const TextStyle(
                                color: KineticTokens.zincGray,
                                fontSize: 11,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: AlignmentDirectional.center,
                              child: TextButton(
                                onPressed: busy
                                    ? null
                                    : () {
                                        final back = widget.onBackToLogin;
                                        if (back != null) {
                                          back();
                                          return;
                                        }
                                        context.read<AuthBloc>().add(
                                          const AuthLoginRequested(),
                                        );
                                      },
                                child: Text(
                                  'onboarding.register.have_account'.tr(),
                                  style: const TextStyle(
                                    color: KineticTokens.electricLime,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
      body: Column(
        children: [
          const StitchPulseTopBar(),
          Expanded(
            child: Center(
              child: StitchKineticCard(
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
                    StitchGhostButton(
                      label: 'onboarding.register.back_login'.tr(),
                      onTap: () => context.read<AuthBloc>().add(
                        const AuthSignOutRequested(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
