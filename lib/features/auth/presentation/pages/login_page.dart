import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fithub_portal_admin/config/theme/app_colors.dart';
import 'package:fithub_portal_admin/core/i18n/app_locales.dart';
import 'package:fithub_portal_admin/core/network/supabase_locale_headers.dart';
import 'package:fithub_portal_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fithub_portal_admin/features/auth/presentation/widgets/stitch_auth_snackbar.dart';

/// Stitch screen `Web Admin Login Portal`
/// (`projects/.../screens/c12b687f1538452ebaf8d0adb89a9489`).
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    context.read<AuthBloc>().add(
          AuthSignInSubmitted(
            email: _emailController.text,
            password: _passwordController.text,
          ),
        );
  }

  Future<void> _setLocale(Locale locale) async {
    await context.setLocale(locale);
    SupabaseLocaleHeaders.apply(locale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current is AuthUnauthenticated &&
          current.message != null &&
          current.message!.isNotEmpty,
      listener: (context, state) {
        if (state is AuthUnauthenticated && state.message != null) {
          StitchAuthSnackbar.show(context, state.message!.tr());
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            const _AmbientGlow(),
            SafeArea(
              child: Align(
                alignment: AlignmentDirectional.topEnd,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(top: 8, end: 16),
                  child: _LocaleToggle(
                    locale: context.locale,
                    onSelect: _setLocale,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 448),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Text(
                            'auth.login.brand'.tr(),
                            textAlign: TextAlign.center,
                            style: textTheme.displayLarge?.copyWith(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                              letterSpacing: -1.5,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'auth.login.subtitle'.tr(),
                            textAlign: TextAlign.center,
                            style: textTheme.labelLarge?.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 2.4,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 48),
                          _LoginCard(
                            obscure: _obscure,
                            emailController: _emailController,
                            passwordController: _passwordController,
                            onToggleObscure: () =>
                                setState(() => _obscure = !_obscure),
                            onSubmit: _submit,
                          ),
                          const SizedBox(height: 48),
                          const _FooterLinks(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocaleToggle extends StatelessWidget {
  const _LocaleToggle({
    required this.locale,
    required this.onSelect,
  });

  final Locale locale;
  final Future<void> Function(Locale locale) onSelect;

  @override
  Widget build(BuildContext context) {
    final isEn = locale.languageCode == 'en';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LocaleChip(
          label: 'auth.login.locale_en'.tr(),
          selected: isEn,
          onTap: () => onSelect(AppLocales.en),
        ),
        const SizedBox(width: 8),
        _LocaleChip(
          label: 'auth.login.locale_ar'.tr(),
          selected: !isEn,
          onTap: () => onSelect(AppLocales.ar),
        ),
      ],
    );
  }
}

class _LocaleChip extends StatelessWidget {
  const _LocaleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primaryContainer.withValues(alpha: 0.2)
          : AppColors.surfaceContainer,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected
                  ? AppColors.primaryContainer
                  : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Container(
          width: 800,
          height: 800,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryContainer.withValues(alpha: 0.03),
          ),
        ),
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.obscure,
    required this.emailController,
    required this.passwordController,
    required this.onToggleObscure,
    required this.onSubmit,
  });

  final bool obscure;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final loading = context.select(
      (AuthBloc b) => b.state is AuthLoading,
    );
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD8E2FF).withValues(alpha: 0.04),
            blurRadius: 60,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              decoration: const BoxDecoration(
                gradient: AppColors.kineticCta,
                borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'auth.login.credential_label'.tr(),
                  textAlign: TextAlign.start,
                  style: textTheme.labelLarge?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.primary,
                    fontSize: 16,
                  ),
                  decoration: _underlineDecoration(
                    context,
                    hint: 'auth.login.credential_hint'.tr(),
                    prefix: Icons.person_outline,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'auth.login.credential_required'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'auth.login.access_key_label'.tr(),
                        textAlign: TextAlign.start,
                        style: textTheme.labelLarge?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => StitchAuthSnackbar.show(
                        context,
                        'auth.login.recover_key_unavailable'.tr(),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.secondary,
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'auth.login.recover_key'.tr(),
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: passwordController,
                  obscureText: obscure,
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.primary,
                    fontSize: 16,
                  ),
                  decoration: _underlineDecoration(
                    context,
                    hint: '••••••••',
                    prefix: Icons.lock_outline,
                    suffix: IconButton(
                      onPressed: onToggleObscure,
                      icon: Icon(
                        obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.outline,
                        size: 20,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'auth.login.access_key_required'.tr();
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => onSubmit(),
                ),
                const SizedBox(height: 24),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.kineticCta,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: loading ? null : onSubmit,
                      borderRadius: BorderRadius.circular(6),
                      child: SizedBox(
                        height: 52,
                        child: Center(
                          child: loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.onPrimaryContainer,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'auth.login.cta_initialize_session'.tr(),
                                      style: textTheme.titleMedium?.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.2,
                                        color: AppColors.onPrimaryContainer,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.arrow_forward,
                                      size: 18,
                                      color: AppColors.onPrimaryContainer,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    const Expanded(
                      child: Divider(color: AppColors.surfaceContainerHighest),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'auth.login.or_social'.tr(),
                        style: textTheme.labelLarge?.copyWith(
                          fontSize: 11,
                          letterSpacing: 2,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(color: AppColors.surfaceContainerHighest),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SocialButton(
                  icon: Icons.login,
                  label: 'auth.login.continue_google'.tr(),
                  onTap: () => StitchAuthSnackbar.show(
                    context,
                    'auth.login.social_out_of_scope'.tr(),
                  ),
                ),
                const SizedBox(height: 12),
                _SocialButton(
                  icon: Icons.devices,
                  label: 'auth.login.continue_apple'.tr(),
                  onTap: () => StitchAuthSnackbar.show(
                    context,
                    'auth.login.social_out_of_scope'.tr(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _underlineDecoration(
    BuildContext context, {
    required String hint,
    required IconData prefix,
    Widget? suffix,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return InputDecoration(
      hintText: hint,
      hintStyle: textTheme.bodyLarge?.copyWith(
        fontSize: 16,
        color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
      ),
      prefixIcon: Icon(prefix, color: AppColors.outline, size: 20),
      suffixIcon: suffix,
      filled: false,
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
      border: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0x4D444933)),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0x4D444933)),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.primaryContainer),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: AppColors.primary),
      label: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              color: AppColors.primary,
            ),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: AppColors.surfaceContainer,
        side: BorderSide(
          color: AppColors.outlineVariant.withValues(alpha: 0.15),
        ),
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }
}

class _FooterLinks extends StatelessWidget {
  const _FooterLinks();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: TextButton(
                onPressed: () {},
                child: Text(
                  'auth.login.privacy'.tr(),
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: TextButton(
                onPressed: () {},
                child: Text(
                  'auth.login.terms'.tr(),
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'auth.login.copyright'.tr(),
          textAlign: TextAlign.center,
          style: textTheme.labelSmall?.copyWith(
            fontSize: 10,
            letterSpacing: 1.6,
            color: AppColors.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }
}
