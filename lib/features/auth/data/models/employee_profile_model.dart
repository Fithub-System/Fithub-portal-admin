import 'package:fithub_portal_admin/features/auth/domain/entities/employee_profile.dart';

class EmployeeProfileModel extends EmployeeProfile {
  const EmployeeProfileModel({
    required super.id,
    required super.tenantId,
    required super.userId,
    required super.name,
    required super.role,
  });

  factory EmployeeProfileModel.fromJson(Map<String, dynamic> json) {
    return EmployeeProfileModel(
      id: json['id']?.toString() ?? '',
      tenantId: json['tenant_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
    );
  }

  factory EmployeeProfileModel.fromCache(Map<String, String> cache) {
    return EmployeeProfileModel(
      id: cache['id']!,
      tenantId: cache['tenant_id']!,
      userId: cache['user_id']!,
      name: cache['name']!,
      role: cache['role']!,
    );
  }

  Map<String, String> toCacheMap() => {
    'id': id,
    'tenant_id': tenantId,
    'user_id': userId,
    'name': name,
    'role': role,
  };
}
