import '../entities/class_session.dart';

abstract class ClassSessionsRepository {
  Future<List<ClassSession>> listSessions();

  Future<List<ClassCoachOption>> listCoaches();

  /// Create or update via RPC `upsert_class_session` only.
  Future<ClassSession> upsertSession({
    String? id,
    required String title,
    required DateTime startsAt,
    required DateTime endsAt,
    required int capacity,
    String? coachEmployeeId,
    String status = 'scheduled',
  });
}
