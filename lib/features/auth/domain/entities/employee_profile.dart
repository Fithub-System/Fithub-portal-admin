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

  /// FEAT-07 AC-A3 / AC-B4 — only Admin may create/assign memberships.
  bool get canManageMemberships => role == 'Admin';

  /// FEAT-13 AC-B4 — only Admin may enroll members (Receptionist denied).
  bool get canEnrollMembers => role == 'Admin';

  /// FEAT-08 AC-B1 — only Admin may update charge status / apply freeze.
  bool get canManageBilling => role == 'Admin';

  /// FEAT-10 AC-D / US-D — only Admin may mutate SKU via set_gym_sku_settings.
  bool get canManageSkuSettings => role == 'Admin';

  /// FEAT-18 AC-B2 — only Admin may upsert/cancel class sessions.
  bool get canManageClassSessions => role == 'Admin';

  @override
  List<Object?> get props => [id, tenantId, userId, name, role];
}
