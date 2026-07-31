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

final class AddMemberPlanSelected extends AddMemberEvent {
  const AddMemberPlanSelected(this.planId);
  final String? planId;

  @override
  List<Object?> get props => [planId];
}

final class AddMemberEnrollRequested extends AddMemberEvent {
  const AddMemberEnrollRequested();
}

final class AddMemberMessageCleared extends AddMemberEvent {
  const AddMemberMessageCleared();
}

final class AddMemberReset extends AddMemberEvent {
  const AddMemberReset();
}
