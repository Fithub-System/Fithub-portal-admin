part of 'class_sessions_cubit.dart';

enum ClassSessionsStatus { initial, loading, ready, failure }

class ClassSessionsState extends Equatable {
  const ClassSessionsState({
    this.status = ClassSessionsStatus.initial,
    required this.weekStart,
    this.sessions = const [],
    this.coaches = const [],
    this.selectedSessionId,
    this.editingSessionId,
    this.draftStartsAt,
    this.draftEndsAt,
    this.busy = false,
    this.messageKey,
  });

  final ClassSessionsStatus status;

  /// Monday 00:00 local of the visible week.
  final DateTime weekStart;
  final List<ClassSession> sessions;
  final List<ClassCoachOption> coaches;
  final String? selectedSessionId;
  final String? editingSessionId;
  final DateTime? draftStartsAt;
  final DateTime? draftEndsAt;
  final bool busy;
  final String? messageKey;

  ClassSession? get selectedSession {
    final id = selectedSessionId;
    if (id == null) return null;
    for (final s in sessions) {
      if (s.id == id) return s;
    }
    return null;
  }

  ClassSession? get editingSession {
    final id = editingSessionId;
    if (id == null) return null;
    for (final s in sessions) {
      if (s.id == id) return s;
    }
    return null;
  }

  DateTime get weekEnd => weekStart.add(const Duration(days: 6));

  List<ClassSession> get sessionsInWeek {
    final endExclusive = weekStart.add(const Duration(days: 7));
    return sessions
        .where(
          (s) =>
              !s.startsAt.isBefore(weekStart) &&
              s.startsAt.isBefore(endExclusive),
        )
        .toList(growable: false);
  }

  ClassSessionsState copyWith({
    ClassSessionsStatus? status,
    DateTime? weekStart,
    List<ClassSession>? sessions,
    List<ClassCoachOption>? coaches,
    String? selectedSessionId,
    bool clearSelected = false,
    String? editingSessionId,
    bool clearEditing = false,
    DateTime? draftStartsAt,
    DateTime? draftEndsAt,
    bool clearDraft = false,
    bool? busy,
    String? messageKey,
    bool clearMessage = false,
  }) {
    return ClassSessionsState(
      status: status ?? this.status,
      weekStart: weekStart ?? this.weekStart,
      sessions: sessions ?? this.sessions,
      coaches: coaches ?? this.coaches,
      selectedSessionId: clearSelected
          ? null
          : (selectedSessionId ?? this.selectedSessionId),
      editingSessionId: clearEditing
          ? null
          : (editingSessionId ?? this.editingSessionId),
      draftStartsAt: clearDraft ? null : (draftStartsAt ?? this.draftStartsAt),
      draftEndsAt: clearDraft ? null : (draftEndsAt ?? this.draftEndsAt),
      busy: busy ?? this.busy,
      messageKey: clearMessage ? null : (messageKey ?? this.messageKey),
    );
  }

  @override
  List<Object?> get props => [
    status,
    weekStart,
    sessions,
    coaches,
    selectedSessionId,
    editingSessionId,
    draftStartsAt,
    draftEndsAt,
    busy,
    messageKey,
  ];
}
