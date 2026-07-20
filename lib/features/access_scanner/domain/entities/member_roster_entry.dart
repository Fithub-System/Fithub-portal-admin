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
  });

  final String id;
  final String fullName;
  final String? avatarUrl;
  final int powerScore;
  final String cryptoSalt;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    fullName,
    avatarUrl,
    powerScore,
    cryptoSalt,
    createdAt,
  ];
}
