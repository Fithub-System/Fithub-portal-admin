part of 'add_member_bloc.dart';

sealed class AddMemberEvent extends Equatable {
  const AddMemberEvent();

  @override
  List<Object?> get props => [];
}

final class AddMemberStarted extends AddMemberEvent {
  const AddMemberStarted();
}

final class AddMemberFindRequested extends AddMemberEvent {
  const AddMemberFindRequested(this.email);
  final String email;

  @override
  List<Object?> get props => [email];
}

/// Debounced desk search (name / phone / public_code / email).
final class AddMemberSearchRequested extends AddMemberEvent {
  const AddMemberSearchRequested(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

final class AddMemberMatchSelected extends AddMemberEvent {
  const AddMemberMatchSelected(this.match);
  final AthleteEnrollMatch? match;

  @override
  List<Object?> get props => [match];
}

final class AddMemberWizardStepChanged extends AddMemberEvent {
  const AddMemberWizardStepChanged(this.step);
  final int step;

  @override
  List<Object?> get props => [step];
}

final class AddMemberPlanSelected extends AddMemberEvent {
  const AddMemberPlanSelected(this.planId);
  final String? planId;

  @override
  List<Object?> get props => [planId];
}

final class AddMemberInvitePlanSelected extends AddMemberEvent {
  const AddMemberInvitePlanSelected(this.planId);
  final String? planId;

  @override
  List<Object?> get props => [planId];
}

final class AddMemberEnrollRequested extends AddMemberEvent {
  const AddMemberEnrollRequested();
}

/// FEAT-62 Invite — [identifier] is email or username.
final class AddMemberInviteRequested extends AddMemberEvent {
  const AddMemberInviteRequested({required this.identifier, this.displayName});

  final String identifier;
  final String? displayName;

  @override
  List<Object?> get props => [identifier, displayName];
}

final class AddMemberMessageCleared extends AddMemberEvent {
  const AddMemberMessageCleared();
}

final class AddMemberReset extends AddMemberEvent {
  const AddMemberReset();
}
