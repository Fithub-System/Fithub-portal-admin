part of 'memberships_cubit.dart';

enum MembershipsStatus { initial, loading, ready, failure }

class MembershipsState extends Equatable {
  const MembershipsState({
    this.status = MembershipsStatus.initial,
    this.plans = const [],
    this.athletes = const [],
    this.freezePolicies = const [],
    this.busy = false,
    this.messageKey,
  });

  final MembershipsStatus status;
  final List<MembershipPlan> plans;
  final List<MembershipAthleteOption> athletes;
  final List<FreezePolicy> freezePolicies;
  final bool busy;
  final String? messageKey;

  MembershipsState copyWith({
    MembershipsStatus? status,
    List<MembershipPlan>? plans,
    List<MembershipAthleteOption>? athletes,
    List<FreezePolicy>? freezePolicies,
    bool? busy,
    String? messageKey,
    bool clearMessage = false,
  }) {
    return MembershipsState(
      status: status ?? this.status,
      plans: plans ?? this.plans,
      athletes: athletes ?? this.athletes,
      freezePolicies: freezePolicies ?? this.freezePolicies,
      busy: busy ?? this.busy,
      messageKey: clearMessage ? null : (messageKey ?? this.messageKey),
    );
  }

  @override
  List<Object?> get props => [
    status,
    plans,
    athletes,
    freezePolicies,
    busy,
    messageKey,
  ];
}
