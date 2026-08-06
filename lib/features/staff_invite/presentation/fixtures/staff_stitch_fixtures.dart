import '../widgets/staff_shift_models.dart';

/// Stitch Staff Management sample chrome (§4.1 fixtures).
///
/// Screen `dcc070ef2b1e45058b3e042ad70140e3` — Staff Profile Creator + Shift Log.
abstract final class StaffStitchFixtures {
  static const String activeShiftsValue = '14';

  static const String nameHint = 'Johnathan Wick';
  static const String emailHint = 'j.wick@kinetic.com';
  static const String emergencyHint = '+1 (555) 000-0000';

  static const List<String> specializationOptions = [
    'Hypertrophy Specialist',
    'Front Desk Operations',
    'Executive Management',
    'Physiotherapist',
  ];

  static const List<StaffShiftFixtureRow> shiftRows = [
    StaffShiftFixtureRow(
      fullName: 'Elena Rodriguez',
      email: 'elena.r@kinetic.com',
      role: StaffShiftRoleKind.trainer,
      clockIn: '05:54 AM',
      clockOut: '02:15 PM',
      totalHours: '8.35h',
      onShift: true,
      initials: 'ER',
      avatarAccent: StaffAvatarAccent.lime,
    ),
    StaffShiftFixtureRow(
      fullName: 'Marcus Thorne',
      email: 'm.thorne@kinetic.com',
      role: StaffShiftRoleKind.admin,
      clockIn: '08:00 AM',
      clockOut: '--:--',
      totalHours: '6.00h',
      onShift: true,
      initials: 'MT',
      avatarAccent: StaffAvatarAccent.neutral,
    ),
    StaffShiftFixtureRow(
      fullName: 'Sarah Jenkins',
      email: 's.jenkins@kinetic.com',
      role: StaffShiftRoleKind.frontDesk,
      clockIn: '04:00 AM',
      clockOut: '12:00 PM',
      totalHours: '8.00h',
      onShift: false,
      initials: 'SJ',
      avatarAccent: StaffAvatarAccent.neutral,
    ),
    StaffShiftFixtureRow(
      fullName: 'Alex Chen',
      email: 'a.chen@kinetic.com',
      role: StaffShiftRoleKind.trainer,
      clockIn: '10:00 AM',
      clockOut: '--:--',
      totalHours: '4.00h',
      onShift: true,
      initials: 'AC',
      avatarAccent: StaffAvatarAccent.neutral,
    ),
  ];

  static const List<StaffAuditFixtureItem> auditItems = [
    StaffAuditFixtureItem(
      title: 'Updated Permissions: Elena Rodriguez',
      meta: '2 hours ago • Admin Admin',
    ),
    StaffAuditFixtureItem(
      title: 'New Profile Created: Sarah Jenkins',
      meta: 'Yesterday • System Automated',
    ),
  ];

  static const String securityTitle = 'Security\nCompliance';
  static const String securityBody =
      'All administrative changes are logged and encrypted per ISO-27001 standards.';
  static const String securityBadge = 'System Secure';
}
