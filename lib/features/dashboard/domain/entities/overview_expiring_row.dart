/// Expiring-memberships table row for Admin Overview (live or fixture).
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
