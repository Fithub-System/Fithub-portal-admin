import 'package:equatable/equatable.dart';

/// Tenant membership plan (`public.membership_plans`).
class MembershipPlan extends Equatable {
  const MembershipPlan({
    required this.id,
    required this.tenantId,
    required this.name,
    this.description,
    required this.durationDays,
    required this.priceCents,
    required this.currency,
    required this.isActive,
  });

  final String id;
  final String tenantId;
  final String name;
  final String? description;
  final int durationDays;
  final int priceCents;
  final String currency;
  final bool isActive;

  @override
  List<Object?> get props => [
    id,
    tenantId,
    name,
    description,
    durationDays,
    priceCents,
    currency,
    isActive,
  ];
}

/// Roster athlete option for assign picker.
class MembershipAthleteOption extends Equatable {
  const MembershipAthleteOption({
    required this.id,
    required this.fullName,
  });

  final String id;
  final String fullName;

  @override
  List<Object?> get props => [id, fullName];
}
