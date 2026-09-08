import 'package:equatable/equatable.dart';

/// FEAT-61 freeze policy row from `list_freeze_policies`.
class FreezePolicy extends Equatable {
  const FreezePolicy({
    required this.id,
    required this.tenantId,
    this.planId,
    required this.freezeDays,
    required this.maxFreezeDaysPerTime,
  });

  final String id;
  final String tenantId;

  /// Null = tenant-wide general policy.
  final String? planId;
  final int freezeDays;
  final int maxFreezeDaysPerTime;

  bool get isGeneral => planId == null;

  @override
  List<Object?> get props => [
    id,
    tenantId,
    planId,
    freezeDays,
    maxFreezeDaysPerTime,
  ];
}

/// Per-plan override wins over general when [planId] matches.
FreezePolicy? resolveFreezePolicy(
  List<FreezePolicy> policies,
  String? planId,
) {
  if (planId != null) {
    for (final p in policies) {
      if (p.planId == planId) return p;
    }
  }
  for (final p in policies) {
    if (p.isGeneral) return p;
  }
  return null;
}
