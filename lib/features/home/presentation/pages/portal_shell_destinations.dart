/// Shell nav indices (Stitch-aligned Portal destinations).
///
/// FEAT-08 adds Marketing & Promotions (`c3207a6938bf40a7872dde7532020ef9`)
/// for the Billing section — not a freehand root tab.
abstract final class PortalShellDestinations {
  static const int dashboard = 0;
  static const int scan = 1;
  static const int memberships = 2;
  static const int marketing = 3;
  static const int account = 4;

  static const int destinationCount = 5;
}
