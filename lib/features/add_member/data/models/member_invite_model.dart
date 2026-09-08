import '../../domain/entities/member_invite.dart';

/// JSON DTO for Edge `invite-member` request / response.
class MemberInviteModel {
  const MemberInviteModel({
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

  factory MemberInviteModel.fromJson(Map<String, dynamic> json) {
    return MemberInviteModel(
      inviteId: '${json['invite_id'] ?? ''}',
      email: '${json['email'] ?? ''}',
      tenantId: '${json['tenant_id'] ?? ''}',
      message: '${json['message'] ?? ''}',
      username: _nullableString(json['username']),
      planId: _nullableString(json['plan_id']),
      expiresAt: _nullableString(json['expires_at']),
      otpEmailSent: json['otp_email_sent'] != false,
    );
  }

  MemberInviteResult toEntity() {
    return MemberInviteResult(
      inviteId: inviteId,
      email: email,
      tenantId: tenantId,
      message: message,
      username: username,
      planId: planId,
      expiresAt: expiresAt,
      otpEmailSent: otpEmailSent,
    );
  }

  /// Body matching Backend Edge `invite-member` contract.
  static Map<String, dynamic> toRequestJson(MemberInvite invite) {
    final body = <String, dynamic>{};
    final email = invite.email?.trim();
    final username = invite.username?.trim();
    if (email != null && email.isNotEmpty) {
      body['email'] = email.toLowerCase();
    }
    if (username != null && username.isNotEmpty) {
      body['username'] = username.toLowerCase();
    }
    final displayName = invite.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      body['display_name'] = displayName;
    }
    final planId = invite.planId?.trim();
    if (planId != null && planId.isNotEmpty) {
      body['plan_id'] = planId;
    }
    return body;
  }

  static String? _nullableString(Object? value) {
    if (value == null) return null;
    final s = '$value'.trim();
    return s.isEmpty ? null : s;
  }
}
