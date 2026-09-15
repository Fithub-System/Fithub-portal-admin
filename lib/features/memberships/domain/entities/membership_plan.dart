import 'package:equatable/equatable.dart';

/// Checkout pass type — `membership_plans.pass_kind` (FEAT-91).
enum MembershipPassKind { singleBranch, roaming }

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
    this.passKind = MembershipPassKind.singleBranch,
  });

  final String id;
  final String tenantId;
  final String name;
  final String? description;
  final int durationDays;
  final int priceCents;
  final String currency;
  final bool isActive;
  final MembershipPassKind passKind;

  String get passKindWire => switch (passKind) {
    MembershipPassKind.singleBranch => 'single_branch',
    MembershipPassKind.roaming => 'roaming',
  };

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
    passKind,
  ];
}

/// Parses PostgREST `pass_kind`. Unknown / null → single branch.
MembershipPassKind membershipPassKindFromWire(Object? raw) {
  final value = raw?.toString().trim().toLowerCase() ?? '';
  if (value == 'roaming') return MembershipPassKind.roaming;
  return MembershipPassKind.singleBranch;
}

/// Wire value for INSERT (`single_branch` | `roaming`).
String membershipPassKindToWire(MembershipPassKind kind) {
  return switch (kind) {
    MembershipPassKind.singleBranch => 'single_branch',
    MembershipPassKind.roaming => 'roaming',
  };
}

/// Roster athlete option for assign picker.
class MembershipAthleteOption extends Equatable {
  const MembershipAthleteOption({required this.id, required this.fullName});

  final String id;
  final String fullName;

  @override
  List<Object?> get props => [id, fullName];
}
