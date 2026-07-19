part of 'staff_invite_bloc.dart';

sealed class StaffInviteState extends Equatable {
  const StaffInviteState({
    this.selectedRole = StaffRole.coach,
    this.messageKey,
    this.messageText,
  });

  final StaffRole selectedRole;

  /// i18n key for success / error snackbars.
  final String? messageKey;

  /// Raw server message when not an i18n key.
  final String? messageText;

  bool get isSuccessMessage =>
      messageKey == 'staff_invite.success' ||
      (messageText != null && messageKey == null);

  @override
  List<Object?> get props => [selectedRole, messageKey, messageText];
}

final class StaffInviteFormState extends StaffInviteState {
  const StaffInviteFormState({
    super.selectedRole,
    super.messageKey,
    super.messageText,
  });
}

final class StaffInviteSubmitting extends StaffInviteState {
  const StaffInviteSubmitting({required super.selectedRole});
}

final class StaffInviteSuccess extends StaffInviteState {
  const StaffInviteSuccess({required super.selectedRole, required this.result})
    : super(messageKey: 'staff_invite.success');

  final StaffInviteResult result;

  @override
  List<Object?> get props => [...super.props, result];
}
