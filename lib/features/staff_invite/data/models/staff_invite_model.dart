import '../../domain/entities/staff_invite.dart';
import '../../domain/entities/staff_role.dart';

/// JSON DTO for `invite-staff` Edge Function response.
class StaffInviteModel {
  const StaffInviteModel({
    required this.employeeId,
    required this.userId,
    required this.tenantId,
    required this.role,
    required this.message,
    required this.emailConfirmRequired,
  });

  final String employeeId;
  final String userId;
  final String tenantId;
  final String role;
  final String message;
  final bool emailConfirmRequired;

  factory StaffInviteModel.fromJson(Map<String, dynamic> json) {
    return StaffInviteModel(
      employeeId: '${json['employee_id'] ?? ''}',
      userId: '${json['user_id'] ?? ''}',
      tenantId: '${json['tenant_id'] ?? ''}',
      role: '${json['role'] ?? ''}',
      message: '${json['message'] ?? ''}',
      emailConfirmRequired: json['email_confirm_required'] == true,
    );
  }

  StaffInviteResult toEntity() {
    return StaffInviteResult(
      employeeId: employeeId,
      userId: userId,
      tenantId: tenantId,
      role: StaffRole.tryParse(role) ?? StaffRole.receptionist,
      message: message,
      emailConfirmRequired: emailConfirmRequired,
    );
  }

  /// Request body matching Backend `invite_staff(email, role, name)`.
  static Map<String, String> toRequestJson(StaffInvite invite) => {
    'email': invite.email,
    'role': invite.role.apiValue,
    'name': invite.name,
  };
}
