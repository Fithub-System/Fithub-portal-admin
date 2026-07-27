/// Auth / profile resolve failures surfaced as Stitch error snackbars.
///
/// [message] holds an EasyLocalization key (`auth.error.*`), translated at UI.
sealed class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

final class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure([
    super.message = 'auth.error.invalid_credentials',
  ]);
}

final class EmployeeProfileMissingFailure extends AuthFailure {
  const EmployeeProfileMissingFailure([
    super.message = 'auth.error.employee_profile_missing',
  ]);
}

/// Portal allows Admin | Receptionist only (FEAT-02 §4.2).
final class WrongAppRoleFailure extends AuthFailure {
  const WrongAppRoleFailure([super.message = 'auth.error.wrong_app_role']);
}

final class AuthNotConfiguredFailure extends AuthFailure {
  const AuthNotConfiguredFailure([super.message = 'auth.error.not_configured']);
}

final class AuthUnknownFailure extends AuthFailure {
  /// [message] may be an i18n key (`auth.error.unknown`) or a raw diagnostic
  /// string (e.g. PostgREST/RLS) shown as-is when it does not look like a key.
  const AuthUnknownFailure([super.message = 'auth.error.unknown']);
}
