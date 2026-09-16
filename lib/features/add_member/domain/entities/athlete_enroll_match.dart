import 'package:equatable/equatable.dart';

/// Athlete card from `find_athlete_for_enroll` / `search_athletes_for_desk`.
class AthleteEnrollMatch extends Equatable {
  const AthleteEnrollMatch({
    required this.id,
    required this.fullName,
    this.publicCode,
    this.email,
    this.phoneE164,
    this.avatarUrl,
    this.membershipStatus,
    this.membershipPlanName,
    this.isMember = false,
  });

  final String id;
  final String fullName;
  final String? publicCode;
  final String? email;
  final String? phoneE164;
  final String? avatarUrl;
  final String? membershipStatus;
  final String? membershipPlanName;
  final bool isMember;

  @override
  List<Object?> get props => [
    id,
    fullName,
    publicCode,
    email,
    phoneE164,
    avatarUrl,
    membershipStatus,
    membershipPlanName,
    isMember,
  ];
}
