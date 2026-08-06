import '../../domain/entities/class_session.dart';
import '../../domain/repositories/class_sessions_repository.dart';
import '../data_sources/remote/class_sessions_remote_data_source.dart';

class ClassSessionsRepositoryImpl implements ClassSessionsRepository {
  ClassSessionsRepositoryImpl({required ClassSessionsRemoteDataSource remote})
    : _remote = remote;

  final ClassSessionsRemoteDataSource _remote;

  @override
  Future<List<ClassSession>> listSessions() => _remote.listSessions();

  @override
  Future<List<ClassCoachOption>> listCoaches() => _remote.listCoaches();

  @override
  Future<ClassSession> upsertSession({
    String? id,
    required String title,
    required DateTime startsAt,
    required DateTime endsAt,
    required int capacity,
    String? coachEmployeeId,
    String status = 'scheduled',
  }) {
    return _remote.upsertSession(
      id: id,
      title: title,
      startsAt: startsAt,
      endsAt: endsAt,
      capacity: capacity,
      coachEmployeeId: coachEmployeeId,
      status: status,
    );
  }
}
