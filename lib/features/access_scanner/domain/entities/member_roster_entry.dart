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
    this.membershipStatus,
    this.membershipPlanName,
    this.membershipEndsAt,
  });

  final String id;
  final String fullName;
  final String? avatarUrl;
  final int powerScore;
  final String cryptoSalt;
  final DateTime createdAt;
  final String? membershipStatus;
  final String? membershipPlanName;
  final DateTime? membershipEndsAt;

  MemberRosterEntry copyWith({
    String? membershipStatus,
    String? membershipPlanName,
    DateTime? membershipEndsAt,
  }) {
    return MemberRosterEntry(
      id: id,
      fullName: fullName,
      avatarUrl: avatarUrl,
      powerScore: powerScore,
      cryptoSalt: cryptoSalt,
      createdAt: createdAt,
      membershipStatus: membershipStatus ?? this.membershipStatus,
      membershipPlanName: membershipPlanName ?? this.membershipPlanName,
      membershipEndsAt: membershipEndsAt ?? this.membershipEndsAt,
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
    membershipStatus,
    membershipPlanName,
    membershipEndsAt,
  ];
}
