part of 'staff_invite_bloc.dart';

sealed class StaffInviteEvent extends Equatable {
  const StaffInviteEvent();

  @override
  List<Object?> get props => [];
}

final class StaffInviteRoleSelected extends StaffInviteEvent {
  const StaffInviteRoleSelected(this.role);

  final StaffRole role;

  @override
  List<Object?> get props => [role];
}

final class StaffInviteSubmitted extends StaffInviteEvent {
  const StaffInviteSubmitted({required this.email, required this.name});

  final String email;
  final String name;

  @override
  List<Object?> get props => [email, name];
}

final class StaffInviteMessageCleared extends StaffInviteEvent {
  const StaffInviteMessageCleared();
}
