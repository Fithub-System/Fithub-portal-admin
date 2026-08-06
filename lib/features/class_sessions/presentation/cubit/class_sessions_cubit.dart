import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/class_sessions_failure.dart';
import '../../domain/entities/class_session.dart';
import '../../domain/use_cases/class_sessions_use_cases.dart';

part 'class_sessions_state.dart';

class ClassSessionsCubit extends Cubit<ClassSessionsState> {
  ClassSessionsCubit({
    required ListClassSessionsUseCase listSessions,
    required ListClassCoachesUseCase listCoaches,
    required UpsertClassSessionUseCase upsertSession,
    DateTime Function()? clock,
  }) : _listSessions = listSessions,
       _listCoaches = listCoaches,
       _upsertSession = upsertSession,
       _clock = clock ?? DateTime.now,
       super(
         ClassSessionsState(
           weekStart: _mondayOf((clock ?? DateTime.now)()),
         ),
       );

  final ListClassSessionsUseCase _listSessions;
  final ListClassCoachesUseCase _listCoaches;
  final UpsertClassSessionUseCase _upsertSession;
  final DateTime Function() _clock;

  static DateTime _mondayOf(DateTime day) {
    final local = DateTime(day.year, day.month, day.day);
    return local.subtract(Duration(days: local.weekday - DateTime.monday));
  }

  Future<void> load() async {
    emit(state.copyWith(status: ClassSessionsStatus.loading, clearMessage: true));
    try {
      final sessions = await _listSessions();
      final coaches = await _listCoaches();
      emit(
        state.copyWith(
          status: ClassSessionsStatus.ready,
          sessions: sessions,
          coaches: coaches,
        ),
      );
    } on ClassSessionsFailure catch (e) {
      emit(
        state.copyWith(
          status: ClassSessionsStatus.failure,
          messageKey: e.messageKey,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ClassSessionsStatus.failure,
          messageKey: const ClassSessionsUnknownFailure().messageKey,
        ),
      );
    }
  }

  void goToToday() {
    emit(state.copyWith(weekStart: _mondayOf(_clock())));
  }

  void shiftWeek(int deltaWeeks) {
    emit(
      state.copyWith(
        weekStart: state.weekStart.add(Duration(days: 7 * deltaWeeks)),
      ),
    );
  }

  void selectSession(ClassSession? session) {
    emit(state.copyWith(selectedSessionId: session?.id, clearSelected: session == null));
  }

  void beginDraftSlot({
    required DateTime startsAt,
    required DateTime endsAt,
  }) {
    emit(
      state.copyWith(
        draftStartsAt: startsAt,
        draftEndsAt: endsAt,
        clearSelected: true,
        editingSessionId: null,
        clearEditing: true,
      ),
    );
  }

  void beginEdit(ClassSession session) {
    emit(
      state.copyWith(
        selectedSessionId: session.id,
        editingSessionId: session.id,
        draftStartsAt: session.startsAt,
        draftEndsAt: session.endsAt,
      ),
    );
  }

  Future<void> createOrUpdate({
    required String title,
    required int capacity,
    String? coachEmployeeId,
    DateTime? startsAt,
    DateTime? endsAt,
  }) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty || capacity < 1) {
      emit(
        state.copyWith(
          messageKey: const ClassSessionsValidationFailure().messageKey,
        ),
      );
      return;
    }

    final start =
        startsAt ??
        state.draftStartsAt ??
        _defaultSlotStart();
    final end =
        endsAt ??
        state.draftEndsAt ??
        start.add(const Duration(hours: 1));
    if (!end.isAfter(start)) {
      emit(
        state.copyWith(
          messageKey: const ClassSessionsValidationFailure().messageKey,
        ),
      );
      return;
    }

    final editingId = state.editingSessionId;
    emit(state.copyWith(busy: true, clearMessage: true));
    try {
      final saved = await _upsertSession(
        id: editingId,
        title: trimmed,
        startsAt: start,
        endsAt: end,
        capacity: capacity,
        coachEmployeeId: coachEmployeeId,
      );
      final sessions = await _listSessions();
      emit(
        state.copyWith(
          busy: false,
          sessions: sessions,
          selectedSessionId: saved.id,
          clearEditing: true,
          clearDraft: true,
          messageKey: editingId == null
              ? 'classes.success.created'
              : 'classes.success.updated',
        ),
      );
    } on ClassSessionsFailure catch (e) {
      emit(state.copyWith(busy: false, messageKey: e.messageKey));
    } catch (_) {
      emit(
        state.copyWith(
          busy: false,
          messageKey: const ClassSessionsUnknownFailure().messageKey,
        ),
      );
    }
  }

  Future<void> softCancel(ClassSession session) async {
    emit(state.copyWith(busy: true, clearMessage: true));
    try {
      await _upsertSession(
        id: session.id,
        title: session.title,
        startsAt: session.startsAt,
        endsAt: session.endsAt,
        capacity: session.capacity,
        coachEmployeeId: session.coachEmployeeId,
        status: 'cancelled',
      );
      final sessions = await _listSessions();
      emit(
        state.copyWith(
          busy: false,
          sessions: sessions,
          clearSelected: true,
          messageKey: 'classes.success.cancelled',
        ),
      );
    } on ClassSessionsFailure catch (e) {
      emit(state.copyWith(busy: false, messageKey: e.messageKey));
    } catch (_) {
      emit(
        state.copyWith(
          busy: false,
          messageKey: const ClassSessionsUnknownFailure().messageKey,
        ),
      );
    }
  }

  DateTime _defaultSlotStart() {
    final now = _clock();
    return DateTime(now.year, now.month, now.day, 9);
  }
}
