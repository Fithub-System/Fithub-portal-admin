/// Shift-log role chrome kinds from Stitch Staff Management.
enum StaffShiftRoleKind { admin, trainer, frontDesk }

/// Avatar fill on Stitch sample rows.
enum StaffAvatarAccent { lime, neutral }

/// One Shift Log sample / fixture row (§4.1).
class StaffShiftFixtureRow {
  const StaffShiftFixtureRow({
    required this.fullName,
    required this.email,
    required this.role,
    required this.clockIn,
    required this.clockOut,
    required this.totalHours,
    required this.onShift,
    required this.initials,
    required this.avatarAccent,
  });

  final String fullName;
  final String email;
  final StaffShiftRoleKind role;
  final String clockIn;
  final String clockOut;
  final String totalHours;
  final bool onShift;
  final String initials;
  final StaffAvatarAccent avatarAccent;
}

/// Recent Audit Actions sample item (§4.1).
class StaffAuditFixtureItem {
  const StaffAuditFixtureItem({required this.title, required this.meta});

  final String title;
  final String meta;
}
