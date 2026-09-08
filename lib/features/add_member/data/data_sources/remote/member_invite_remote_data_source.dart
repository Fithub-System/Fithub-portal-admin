import 'package:fithub_portal_admin/core/network/api_provider.dart';
import 'package:fithub_portal_admin/core/network/app_endpoints.dart';
import 'package:fithub_portal_admin/core/network/network_config.dart';
import 'package:fithub_portal_admin/core/network/supabase_config.dart';
import 'package:fithub_portal_admin/features/add_member/domain/add_member_failure.dart';
import 'package:fithub_portal_admin/features/add_member/domain/entities/member_invite.dart';

import '../../models/member_invite_model.dart';

/// Remote boundary for Edge `invite-member` (FEAT-62).
abstract class MemberInviteRemoteDataSource {
  Future<MemberInviteModel> inviteMember(MemberInvite invite);
}

/// Dio [ApiProvider] adapter → `POST /functions/v1/invite-member`.
///
/// Uses signed-in Admin JWT (see [ApiProvider] bearer) + anon `apikey`.
/// Never embeds service_role (same trust as FEAT-05 staff invite).
class MemberInviteHttpRemoteDataSource implements MemberInviteRemoteDataSource {
  MemberInviteHttpRemoteDataSource(this._api);

  final ApiProvider _api;

  @override
  Future<MemberInviteModel> inviteMember(MemberInvite invite) async {
    if (!NetworkConfig.hasBaseUrl || !SupabaseConfig.isConfigured) {
      throw const AddMemberNotConfiguredFailure();
    }

    try {
      final data = await _api.requestAPI(
        url: AppEndpoints.inviteMember,
        type: RequestType.post,
        body: MemberInviteModel.toRequestJson(invite),
        headers: {'apikey': SupabaseConfig.anonKey},
      );

      if (data is! Map) {
        throw const AddMemberUnknownFailure();
      }
      final map = Map<String, dynamic>.from(data);
      if (map['error'] != null) {
        throw _mapErrorText('${map['error']}');
      }
      final model = MemberInviteModel.fromJson(map);
      if (model.inviteId.isEmpty || model.email.isEmpty) {
        throw const AddMemberUnknownFailure();
      }
      return model;
    } on AddMemberFailure {
      rethrow;
    } on Exception catch (e) {
      final raw = e.toString().replaceFirst('Exception: ', '');
      throw _mapErrorText(raw);
    }
  }

  AddMemberFailure _mapErrorText(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('admin') &&
        (lower.contains('invite') || lower.contains('member'))) {
      return const AddMemberForbiddenFailure();
    }
    if (lower.contains('athlete not found') ||
        lower.contains('not found for username')) {
      return const AddMemberUsernameNotFoundFailure();
    }
    if (lower.contains('otp email') ||
        lower.contains('email failed') ||
        lower.contains('resend')) {
      return const AddMemberInviteEmailFailure();
    }
    if (lower.contains('email or username') ||
        lower.contains('invalid_body') ||
        lower.contains('required')) {
      return const AddMemberValidationFailure(
        'add_member.validation.identifier',
      );
    }
    if (raw.isEmpty) {
      return const AddMemberUnknownFailure();
    }
    // Prefer i18n keys when Edge returns English; keep detail for honest UX.
    if (lower.contains('only admins')) {
      return const AddMemberForbiddenFailure();
    }
    if (lower.contains('failed to create') ||
        lower.contains('invite failed') ||
        lower.contains('resolve')) {
      return AddMemberInviteServerFailure(
        raw.isEmpty ? 'add_member.error.invite_failed' : raw,
      );
    }
    return AddMemberInviteServerFailure(raw);
  }
}
