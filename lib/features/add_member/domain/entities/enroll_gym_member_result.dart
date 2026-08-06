import 'package:equatable/equatable.dart';

/// Result of `enroll_gym_member` RPC (FEAT-13).
class EnrollGymMemberResult extends Equatable {
  const EnrollGymMemberResult({
    required this.tenantId,
    required this.athleteId,
    required this.created,
  });

  final String tenantId;
  final String athleteId;
  final bool created;

  @override
  List<Object?> get props => [tenantId, athleteId, created];
}
