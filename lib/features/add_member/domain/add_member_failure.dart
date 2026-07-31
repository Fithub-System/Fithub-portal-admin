/// Add Member feature failures (i18n keys under `add_member.error.*`).
sealed class AddMemberFailure implements Exception {
  const AddMemberFailure(this.messageKey);
  final String messageKey;

  @override
  String toString() => messageKey;
}

final class AddMemberNotConfiguredFailure extends AddMemberFailure {
  const AddMemberNotConfiguredFailure()
    : super('add_member.error.not_configured');
}

final class AddMemberForbiddenFailure extends AddMemberFailure {
  const AddMemberForbiddenFailure() : super('add_member.error.forbidden');
}

final class AddMemberNotFoundFailure extends AddMemberFailure {
  const AddMemberNotFoundFailure() : super('add_member.error.not_found');
}

final class AddMemberValidationFailure extends AddMemberFailure {
  const AddMemberValidationFailure([
    super.messageKey = 'add_member.error.invalid',
  ]);
}

final class AddMemberUnknownFailure extends AddMemberFailure {
  const AddMemberUnknownFailure() : super('add_member.error.unknown');
}
