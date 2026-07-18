import 'package:fithub_portal_admin/features/auth/domain/entities/employee_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Session? get currentSession;

  Future<EmployeeProfile> signInWithPassword({
    required String email,
    required String password,
  });

  Future<EmployeeProfile> resolveEmployeeProfile();

  Future<void> signOut();

  Future<EmployeeProfile?> readCachedProfile();
}
