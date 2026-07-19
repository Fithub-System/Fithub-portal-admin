import 'package:equatable/equatable.dart';

import 'staff_role.dart';

/// Invite payload for FEAT-05 `invite_staff(email, role, name)`.
class StaffInvite extends Equatable {
  const StaffInvite({
    required this.email,
    required this.role,
    required this.name,
  });

  final String email;
  final StaffRole role;
  final String name;

  @override
  List<Object?> get props => [email, role, name];
}

/// Successful invite response from Edge Function / RPC.
class StaffInviteResult extends Equatable {
  const StaffInviteResult({
    required this.employeeId,
    required this.userId,
    required this.tenantId,
    required this.role,
    required this.message,
    this.emailConfirmRequired = false,
  });

  final String employeeId;
  final String userId;
  final String tenantId;
  final StaffRole role;
  final String message;
  final bool emailConfirmRequired;

  @override
  List<Object?> get props => [
    employeeId,
    userId,
    tenantId,
    role,
    message,
    emailConfirmRequired,
  ];
}
