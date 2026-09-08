part of 'add_member_bloc.dart';

enum AddMemberStatus {
  idle,
  loadingPlans,
  finding,
  found,
  enrolling,
  inviting,
  success,
}

class AddMemberState extends Equatable {
  const AddMemberState({
    this.status = AddMemberStatus.idle,
    this.email = '',
    this.match,
    this.plans = const [],
    this.selectedPlanId,
    this.invitePlanId,
    this.messageKey,
    this.enrollCreated,
    this.assignFailed = false,
  });

  final AddMemberStatus status;
  final String email;
  final AthleteEnrollMatch? match;
  final List<MembershipPlan> plans;
  final String? selectedPlanId;

  /// Optional plan for Invite tab (applied on athlete OTP verify).
  final String? invitePlanId;
  final String? messageKey;
  final bool? enrollCreated;
  final bool assignFailed;

  bool get busy =>
      status == AddMemberStatus.finding ||
      status == AddMemberStatus.enrolling ||
      status == AddMemberStatus.inviting ||
      status == AddMemberStatus.loadingPlans;

  AddMemberState copyWith({
    AddMemberStatus? status,
    String? email,
    AthleteEnrollMatch? match,
    List<MembershipPlan>? plans,
    String? selectedPlanId,
    String? invitePlanId,
    String? messageKey,
    bool? enrollCreated,
    bool? assignFailed,
    bool clearMatch = false,
    bool clearMessage = false,
    bool clearPlan = false,
    bool clearInvitePlan = false,
  }) {
    return AddMemberState(
      status: status ?? this.status,
      email: email ?? this.email,
      match: clearMatch ? null : (match ?? this.match),
      plans: plans ?? this.plans,
      selectedPlanId: clearPlan
          ? null
          : (selectedPlanId ?? this.selectedPlanId),
      invitePlanId: clearInvitePlan
          ? null
          : (invitePlanId ?? this.invitePlanId),
      messageKey: clearMessage ? null : (messageKey ?? this.messageKey),
      enrollCreated: enrollCreated ?? this.enrollCreated,
      assignFailed: assignFailed ?? this.assignFailed,
    );
  }

  @override
  List<Object?> get props => [
    status,
    email,
    match,
    plans,
    selectedPlanId,
    invitePlanId,
    messageKey,
    enrollCreated,
    assignFailed,
  ];
}
