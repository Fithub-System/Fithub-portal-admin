/// Local attendance row pending cloud upsert (mirrors `attendance_logs`).
class PendingAttendance {
  const PendingAttendance({
    required this.id,
    required this.tenantId,
    required this.athleteId,
    required this.checkedInAt,
    this.checkedOutAt,
  });

  final String id;
  final String tenantId;
  final String athleteId;
  final DateTime checkedInAt;
  final DateTime? checkedOutAt;
}
