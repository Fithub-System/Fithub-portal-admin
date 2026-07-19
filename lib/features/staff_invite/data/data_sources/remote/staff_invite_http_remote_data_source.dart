import 'package:fithub_portal_admin/core/network/api_provider.dart';
import 'package:fithub_portal_admin/core/network/app_endpoints.dart';
import 'package:fithub_portal_admin/core/network/network_config.dart';
import 'package:fithub_portal_admin/core/network/supabase_config.dart';

import '../../../domain/entities/staff_invite.dart';
import '../../../domain/staff_invite_failure.dart';
import '../../models/staff_invite_model.dart';
import 'staff_invite_remote_data_source.dart';

/// Dio [ApiProvider] adapter → `POST /functions/v1/invite-staff`.
///
/// Uses the signed-in user JWT (see [ApiProvider] bearer) + anon `apikey`.
/// Never embeds service_role (FEAT-05 AC-C2).
class StaffInviteHttpRemoteDataSource implements StaffInviteRemoteDataSource {
  StaffInviteHttpRemoteDataSource(this._api);

  final ApiProvider _api;

  @override
  Future<StaffInviteModel> inviteStaff(StaffInvite invite) async {
    if (!NetworkConfig.hasBaseUrl || !SupabaseConfig.isConfigured) {
      throw const StaffInviteNotConfiguredFailure();
    }

    try {
      final data = await _api.requestAPI(
        url: AppEndpoints.inviteStaff,
        type: RequestType.post,
        body: StaffInviteModel.toRequestJson(invite),
        headers: {'apikey': SupabaseConfig.anonKey},
      );

      if (data is! Map) {
        throw const StaffInviteServerFailure();
      }
      final map = Map<String, dynamic>.from(data);
      if (map['error'] != null) {
        throw StaffInviteServerFailure('${map['error']}');
      }
      return StaffInviteModel.fromJson(map);
    } on StaffInviteFailure {
      rethrow;
    } on Exception catch (e) {
      final raw = e.toString().replaceFirst('Exception: ', '');
      final lower = raw.toLowerCase();
      if (lower.contains('admin') && lower.contains('invite')) {
        throw StaffInviteForbiddenFailure(
          raw.isEmpty ? 'staff_invite.error.forbidden' : raw,
        );
      }
      throw StaffInviteServerFailure(
        raw.isEmpty ? 'staff_invite.error.unknown' : raw,
      );
    }
  }
}
