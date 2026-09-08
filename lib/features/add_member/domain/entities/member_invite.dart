/// FEAT-62 member invite request + Edge response (no OTP in client).
class MemberInvite {
  const MemberInvite({
    this.email,
    this.username,
    this.displayName,
    this.planId,
  });

  /// Normalized lower-case email when inviting by email.
  final String? email;

  /// Username when inviting an existing athlete (never creates Auth).
  final String? username;

  /// Optional display name for Auth metadata / email greeting.
  final String? displayName;

  /// Optional plan applied on OTP verify.
  final String? planId;
}

/// Safe Edge `invite-member` success payload (OTP never returned in prod).
class MemberInviteResult {
  const MemberInviteResult({
    required this.inviteId,
    required this.email,
    required this.tenantId,
    required this.message,
    this.username,
    this.planId,
    this.expiresAt,
    this.otpEmailSent = true,
  });

  final String inviteId;
  final String email;
  final String tenantId;
  final String message;
  final String? username;
  final String? planId;
  final String? expiresAt;
  final bool otpEmailSent;
}
