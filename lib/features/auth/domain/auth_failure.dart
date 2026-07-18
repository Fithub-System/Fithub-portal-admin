/// Auth / profile resolve failures surfaced as Stitch error snackbars.
sealed class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

final class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure([
    super.message = 'Invalid credentials. Check email and access key.',
  ]);
}

final class EmployeeProfileMissingFailure extends AuthFailure {
  const EmployeeProfileMissingFailure([
    super.message =
        'Employee profile not found. Access denied — contact your gym admin.',
  ]);
}

/// Portal allows Admin | Receptionist only (FEAT-02 §4.2).
final class WrongAppRoleFailure extends AuthFailure {
  const WrongAppRoleFailure([
    super.message =
        'Access denied — Admin Portal is for Admin and Receptionist only. '
        'Coach accounts use the Coach app.',
  ]);
}

final class AuthNotConfiguredFailure extends AuthFailure {
  const AuthNotConfiguredFailure([
    super.message = 'Supabase is not configured for this build.',
  ]);
}

final class AuthUnknownFailure extends AuthFailure {
  const AuthUnknownFailure([super.message = 'Authentication failed.']);
}
