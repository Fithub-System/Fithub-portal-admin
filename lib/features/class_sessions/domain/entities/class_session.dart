import 'package:equatable/equatable.dart';

/// Tenant class session (`public.class_sessions`) — FEAT-18.
class ClassSession extends Equatable {
  const ClassSession({
    required this.id,
    required this.tenantId,
    required this.title,
    required this.startsAt,
    required this.endsAt,
    required this.capacity,
    this.coachEmployeeId,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String tenantId;
  final String title;
  final DateTime startsAt;
  final DateTime endsAt;
  final int capacity;
  final String? coachEmployeeId;

  /// `scheduled` | `cancelled`
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isCancelled => status == 'cancelled';
  bool get isScheduled => status == 'scheduled';

  @override
  List<Object?> get props => [
    id,
    tenantId,
    title,
    startsAt,
    endsAt,
    capacity,
    coachEmployeeId,
    status,
    createdAt,
    updatedAt,
  ];
}

/// Instructor option for Class Manager picker (employees SELECT).
class ClassCoachOption extends Equatable {
  const ClassCoachOption({
    required this.id,
    required this.name,
    required this.role,
  });

  final String id;
  final String name;
  final String role;

  @override
  List<Object?> get props => [id, name, role];
}
