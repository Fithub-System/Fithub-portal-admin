import '../entities/class_session.dart';
import '../repositories/class_sessions_repository.dart';

class ListClassSessionsUseCase {
  const ListClassSessionsUseCase(this._repository);
  final ClassSessionsRepository _repository;

  Future<List<ClassSession>> call() => _repository.listSessions();
}

class ListClassCoachesUseCase {
  const ListClassCoachesUseCase(this._repository);
  final ClassSessionsRepository _repository;

  Future<List<ClassCoachOption>> call() => _repository.listCoaches();
}

class UpsertClassSessionUseCase {
  const UpsertClassSessionUseCase(this._repository);
  final ClassSessionsRepository _repository;

  Future<ClassSession> call({
    String? id,
    required String title,
    required DateTime startsAt,
    required DateTime endsAt,
    required int capacity,
    String? coachEmployeeId,
    String status = 'scheduled',
  }) {
    return _repository.upsertSession(
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
