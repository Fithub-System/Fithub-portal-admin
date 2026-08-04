/// Stitch G1 Access Scanner / Check-in Gate sample chrome (§4.1 fixtures).
///
/// Screen `3629845f7f1e402697f46cf5575e86da` — EN Check-in Gate artboard.
abstract final class AccessGateStitchFixtures {
  static const String readyWaiting = 'Ready - Waiting for Scan';
  static const String confirmCheckIn = 'CONFIRM CHECK-IN';
  static const String accessGranted = 'ACCESS GRANTED';

  static const String systemId = '098-KM-X';
  static const String encryption = 'AES-256';

  static const String latHud = 'LAT: 34.0522 N';
  static const String lngHud = 'LNG: 118.2437 W';

  static const String peakIntensityValue = '94%';
  static const String avgDwellValue = '68 MIN';
  static const String guestPassesValue = '04';

  static const int occupancyCurrent = 42;
  static const int occupancyLimit = 100;

  static const String memberName = 'Marcus Henderson';
  static const String memberPlan = 'Premium Monthly';
  static const String memberActiveBadge = 'Active';
  static const String powerScoreValue = '780';
  static const double powerScoreFraction = 0.78;
  static const String lastCheckIn = 'Yesterday, 18:45';
  static const String totalVisits = '142';
  static const String memberInitials = 'MH';

  static const List<AccessGateLogLine> systemLog = [
    AccessGateLogLine(time: '08:42:01', event: 'GATE_INIT_SUCCESS'),
    AccessGateLogLine(time: '08:45:12', event: 'AUTH_CHECK: M_HENDERSON'),
    AccessGateLogLine(time: '08:45:13', event: 'GRANT_ACCESS: CHANNEL_A'),
    AccessGateLogLine(time: '09:00:00', event: 'SYNC_CLOUD_DEFERRED'),
  ];
}

class AccessGateLogLine {
  const AccessGateLogLine({required this.time, required this.event});

  final String time;
  final String event;
}
