/// Invitable employee roles (FEAT-05 AC-B1 / Backend ALLOWED_ROLES).
enum StaffRole {
  admin('Admin'),
  receptionist('Receptionist'),
  coach('Coach');

  const StaffRole(this.apiValue);

  /// Wire value sent to `invite_staff` / Edge Function.
  final String apiValue;

  static StaffRole? tryParse(String? raw) {
    if (raw == null) return null;
    for (final role in StaffRole.values) {
      if (role.apiValue == raw) return role;
    }
    return null;
  }
}
