import 'package:equatable/equatable.dart';

/// Cloud athlete row scoped to the employee tenant for Drift cache.
class MemberRosterEntry extends Equatable {
  const MemberRosterEntry({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    required this.powerScore,
    required this.cryptoSalt,
    required this.createdAt,
    this.membershipId,
    this.membershipPlanId,
    this.membershipStatus,
    this.membershipPlanName,
    this.membershipEndsAt,
    this.publicCode,
    this.assignedCoachId,
  });

  final String id;
  final String fullName;
  final String? avatarUrl;
  final int powerScore;
  final String cryptoSalt;
  final DateTime createdAt;

  /// FEAT-61 — `athlete_memberships.id` for renew / freeze RPCs.
  final String? membershipId;
  final String? membershipPlanId;
  final String? membershipStatus;
  final String? membershipPlanName;
  final DateTime? membershipEndsAt;

  /// FEAT-95 desk identity `athletes.public_code`.
  final String? publicCode;

  /// FEAT-95 `gym_members.assigned_coach_id`.
  final String? assignedCoachId;

  bool get hasActiveMembership => membershipStatus == 'active';

  bool get hasPausedMembership => membershipStatus == 'paused';

  bool get canRenewMembership =>
      membershipId != null &&
      (membershipStatus == 'active' || membershipStatus == 'scheduled');

  MemberRosterEntry copyWith({
    String? membershipId,
    String? membershipPlanId,
    String? membershipStatus,
    String? membershipPlanName,
    DateTime? membershipEndsAt,
    String? publicCode,
    String? assignedCoachId,
  }) {
    return MemberRosterEntry(
      id: id,
      fullName: fullName,
      avatarUrl: avatarUrl,
      powerScore: powerScore,
      cryptoSalt: cryptoSalt,
      createdAt: createdAt,
      membershipId: membershipId ?? this.membershipId,
      membershipPlanId: membershipPlanId ?? this.membershipPlanId,
      membershipStatus: membershipStatus ?? this.membershipStatus,
      membershipPlanName: membershipPlanName ?? this.membershipPlanName,
      membershipEndsAt: membershipEndsAt ?? this.membershipEndsAt,
      publicCode: publicCode ?? this.publicCode,
      assignedCoachId: assignedCoachId ?? this.assignedCoachId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    fullName,
    avatarUrl,
    powerScore,
    cryptoSalt,
    createdAt,
    membershipId,
    membershipPlanId,
    membershipStatus,
    membershipPlanName,
    membershipEndsAt,
    publicCode,
    assignedCoachId,
  ];
}
