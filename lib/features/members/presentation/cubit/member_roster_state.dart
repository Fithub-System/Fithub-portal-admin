part of 'member_roster_cubit.dart';

enum MemberRosterStatus { initial, loading, ready, failure }

class MemberRosterState extends Equatable {
  const MemberRosterState({
    this.status = MemberRosterStatus.initial,
    this.members = const [],
    this.showingCachedOffline = false,
    this.errorKey,
  });

  final MemberRosterStatus status;
  final List<MemberRosterEntry> members;

  /// FEAT-26 — cached roster readable offline with stale/offline indicator.
  final bool showingCachedOffline;

  /// Cloud sync / cache failure translation key (P0: never hide as empty ready).
  final String? errorKey;

  MemberRosterState copyWith({
    MemberRosterStatus? status,
    List<MemberRosterEntry>? members,
    bool? showingCachedOffline,
    String? errorKey,
    bool clearError = false,
  }) {
    return MemberRosterState(
      status: status ?? this.status,
      members: members ?? this.members,
      showingCachedOffline: showingCachedOffline ?? this.showingCachedOffline,
      errorKey: clearError ? null : (errorKey ?? this.errorKey),
    );
  }

  @override
  List<Object?> get props => [status, members, showingCachedOffline, errorKey];
}
