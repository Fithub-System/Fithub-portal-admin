/// Shell nav indices — FEAT-11 Install I1 Stitch-aligned Portal destinations.
///
/// Order locked: Home | Members | Staff | Classes | Marketing | Reports
/// (`@specs/FEAT-11-PORTAL-SHELL-MATCH-STITCH.md` §2 US-A / §3).
///
/// Stitch citations:
/// - Home `216e0407184f4c39bd501ed436c1e88b`
/// - Members `9b35dd57f15443e99f7e798f6867acb6` (FEAT-07-R)
/// - Staff `dcc070ef2b1e45058b3e042ad70140e3`
/// - Classes empty EN `c3b2a1416ebb4f46a71aa108f418e51c` / AR `747d13fbf3b741d09c3a29e18d7b0bd4`
/// - Marketing `c3207a6938bf40a7872dde7532020ef9` (FEAT-08)
/// - Reports empty EN `ace7bf6e830b4e9f8963cfa5dd07909b` / AR `82188fd0c27a4baa923ead6221e04d7b`
///
/// Removed from rail IA: Scan, Account (FEAT-11 AC-A2 / AC-E2).
abstract final class PortalShellDestinations {
  static const int home = 0;
  static const int members = 1;
  static const int staff = 2;
  static const int classes = 3;
  static const int marketing = 4;
  static const int reports = 5;

  static const int destinationCount = 6;

  /// Alias for Home (legacy dashboard index naming).
  static const int dashboard = home;
}
