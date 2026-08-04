/// Stitch Admin Overview sample chrome (§4.1 fixtures).
///
/// Screen `216e0407184f4c39bd501ed436c1e88b` — Daily Yield, Expiring
/// Memberships, Access Granted sample, footer stats. Live occupancy + FEAT-12
/// Access Gate behavior stay bound when live data exists.
abstract final class OverviewStitchFixtures {
  static const String stitchScreenId = '216e0407184f4c39bd501ed436c1e88b';
  static const String arTwinScreenId = '167e03106e8c45c6b47b8ecb48116624';

  // --- Daily Yield ---
  static const String yieldAmount = r'$12,482';
  static const String yieldDelta = '+14.2% vs yesterday';

  // --- Expiring Memberships ---
  static const List<OverviewExpiringRow> expiringRows = [
    OverviewExpiringRow(
      fullName: 'Marcus Thorne',
      email: 'm.thorne@example.com',
      planLabel: 'ELITE PERFORMANCE',
      expirationDate: 'May 24, 2024',
      relativeLabel: 'Tomorrow',
      urgent: true,
    ),
    OverviewExpiringRow(
      fullName: 'Elena Rodriguez',
      email: 'elena.r@example.com',
      planLabel: 'FOUNDRY BASIC',
      expirationDate: 'May 25, 2024',
      relativeLabel: 'In 2 days',
      urgent: false,
    ),
  ];

  // --- Access Granted sample chrome (artboard always shows this stack) ---
  static const String grantedMemberName = 'John Smith';
  static const String grantedMemberId = '#KM-88219';

  // --- Footer stats ---
  static const String totalActive = '2,841';
  static const String classesToday = '42';
  static const String guestPasses = '12';
  static const String incidentReports = '0';
}

class OverviewExpiringRow {
  const OverviewExpiringRow({
    required this.fullName,
    required this.email,
    required this.planLabel,
    required this.expirationDate,
    required this.relativeLabel,
    required this.urgent,
  });

  final String fullName;
  final String email;
  final String planLabel;
  final String expirationDate;
  final String relativeLabel;
  final bool urgent;
}
