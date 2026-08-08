part of 'member_roster_cubit.dart';

enum MemberRosterStatus { initial, loading, ready, failure }

class MemberRosterState extends Equatable {
  const MemberRosterState({
    this.status = MemberRosterStatus.initial,
    this.members = const [],
    this.showingCachedOffline = false,
  });

  final MemberRosterStatus status;
  final List<MemberRosterEntry> members;

  /// FEAT-26 — cached roster readable offline with stale/offline indicator.
  final bool showingCachedOffline;

  MemberRosterState copyWith({
    MemberRosterStatus? status,
    List<MemberRosterEntry>? members,
    bool? showingCachedOffline,
  }) {
    return MemberRosterState(
      status: status ?? this.status,
      members: members ?? this.members,
      showingCachedOffline: showingCachedOffline ?? this.showingCachedOffline,
    );
  }

  @override
  List<Object?> get props => [status, members, showingCachedOffline];
}
