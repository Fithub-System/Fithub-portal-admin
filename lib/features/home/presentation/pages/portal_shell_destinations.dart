/// Shell nav indices — FEAT-11 / FEAT-30 + owner Settings rail (2026-09-08).
///
/// Order: Home | Members | Staff | Classes | Marketing | Payouts | Settings | Reports
///
/// Settings is an **owner soft lock** (separate rail tab with module ListTiles).
/// Prior FEAT-10 AC-D4 “not a rail tab” is superseded for discoverability.
abstract final class PortalShellDestinations {
  static const int home = 0;
  static const int members = 1;
  static const int staff = 2;
  static const int classes = 3;
  static const int marketing = 4;
  static const int payouts = 5;
  static const int settings = 6;
  static const int reports = 7;

  static const int destinationCount = 8;

  /// Alias for Home (legacy dashboard index naming).
  static const int dashboard = home;
}
