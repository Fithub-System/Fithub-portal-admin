part of 'member_roster_cubit.dart';

enum MemberRosterStatus { initial, loading, ready, failure }

class MemberRosterState extends Equatable {
  const MemberRosterState({
    this.status = MemberRosterStatus.initial,
    this.members = const [],
  });

  final MemberRosterStatus status;
  final List<MemberRosterEntry> members;

  MemberRosterState copyWith({
    MemberRosterStatus? status,
    List<MemberRosterEntry>? members,
  }) {
    return MemberRosterState(
      status: status ?? this.status,
      members: members ?? this.members,
    );
  }

  @override
  List<Object?> get props => [status, members];
}
