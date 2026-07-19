import 'package:equatable/equatable.dart';

/// Resolved `public.employees` row for Portal Admin (FEAT-02 §4.2).
class EmployeeProfile extends Equatable {
  const EmployeeProfile({
    required this.id,
    required this.tenantId,
    required this.userId,
    required this.name,
    required this.role,
  });

  final String id;
  final String tenantId;
  final String userId;
  final String name;
  final String role;

  bool get isPortalRole => role == 'Admin' || role == 'Receptionist';

  /// FEAT-05 AC-B4 — only Admin may invite staff (UI gate; Backend enforces).
  bool get canInviteStaff => role == 'Admin';

  @override
  List<Object?> get props => [id, tenantId, userId, name, role];
}
