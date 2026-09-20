import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../memberships/domain/entities/membership_plan.dart';
import '../../memberships/domain/use_cases/memberships_use_cases.dart';
import '../../staff_invite/domain/entities/staff_invite.dart';
import '../../staff_invite/domain/entities/staff_role.dart';
import '../../staff_invite/domain/use_cases/staff_invite_use_case.dart';

class GymOnboardingSnapshot extends Equatable {
  const GymOnboardingSnapshot({
    required this.gym,
    required this.branches,
    required this.score,
    required this.canPublish,
    required this.checks,
  });

  final Map<String, dynamic> gym;
  final List<Map<String, dynamic>> branches;
  final int score;
  final bool canPublish;
  final List<Map<String, dynamic>> checks;

  @override
  List<Object?> get props => [gym, branches, score, canPublish, checks];
}

class GymOnboardingRemote {
  GymOnboardingRemote({
    required this.createPlan,
    required this.inviteStaff,
    ListMembershipPlansUseCase? listPlans,
    SupabaseClient? client,
  }) : _listPlans = listPlans,
       _client = client;

  final CreateMembershipPlanUseCase createPlan;
  final InviteStaffUseCase inviteStaff;
  final ListMembershipPlansUseCase? _listPlans;
  final SupabaseClient? _client;

  static const placeholderPhoto =
      'https://placehold.co/1280x720/121212/CCFF00.png?text=Pulse+Branch';

  static const amenityTags = <String>[
    'parking',
    'ac',
    'ladies_only',
    'spa',
    'sauna',
    'crossfit',
    'locker_rooms',
    'nutrition_bar',
  ];

  SupabaseClient get _supabase {
    final injected = _client;
    if (injected != null) return injected;
    return Supabase.instance.client;
  }

  Future<GymOnboardingSnapshot> load() async {
    final raw = await _supabase.rpc('gym_onboarding_snapshot');
    final map = Map<String, dynamic>.from(raw as Map);
    final scoreMap = Map<String, dynamic>.from(map['score'] as Map);
    final checks = (scoreMap['checks'] as List? ?? [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    final branches = (map['branches'] as List? ?? [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    return GymOnboardingSnapshot(
      gym: Map<String, dynamic>.from(map['gym'] as Map),
      branches: branches,
      score: (scoreMap['score'] as num?)?.toInt() ?? 0,
      canPublish: scoreMap['can_publish'] == true,
      checks: checks,
    );
  }

  Future<void> saveProfile({
    required String name,
    String? tradingName,
    String? taxId,
    String? contactName,
    String? contactPhone,
    String? contactRole,
    int? estimatedStaffSize,
  }) {
    return _supabase.rpc(
      'upsert_gym_profile',
      params: {
        'p_name': name,
        'p_trading_name': tradingName,
        'p_tax_id': taxId,
        'p_contact_name': contactName,
        'p_contact_phone_e164': contactPhone,
        'p_contact_role': contactRole,
        'p_estimated_staff_size': estimatedStaffSize,
      },
    );
  }

  Future<String> saveBranch({
    String? id,
    required String name,
    required String address,
    double? lat,
    double? lng,
    required Map<String, dynamic> hours,
    required int capacity,
    required List<String> photoUrls,
  }) async {
    final raw = await _supabase.rpc(
      'upsert_gym_branch',
      params: {
        'p_id': (id == null || id.isEmpty) ? null : id,
        'p_name': name,
        'p_address': address,
        'p_lat': lat,
        'p_lng': lng,
        'p_hours': hours,
        'p_capacity_ceiling': capacity,
        'p_photo_urls': photoUrls,
      },
    );
    return (raw as Map)['id'].toString();
  }

  Future<void> setFacilities(String branchId, List<String> tags) {
    return _supabase.rpc(
      'set_branch_facilities',
      params: {'p_branch_id': branchId, 'p_tags': tags},
    );
  }

  Future<List<MembershipPlan>> loadPlans() {
    final useCase = _listPlans;
    if (useCase == null) {
      return Future<List<MembershipPlan>>.value(const []);
    }
    return useCase(activeOnly: true);
  }

  Future<void> addPlan({
    required String name,
    required int durationDays,
    required int priceCents,
    required MembershipPassKind passKind,
  }) {
    return createPlan(
      name: name,
      durationDays: durationDays,
      priceCents: priceCents,
      passKind: passKind,
    );
  }

  Future<void> invite({
    required String email,
    required String name,
    required StaffRole role,
  }) {
    return inviteStaff(StaffInvite(email: email, role: role, name: name));
  }

  Future<void> publish(bool visible) {
    return _supabase.rpc(
      'set_marketplace_visible',
      params: {'p_visible': visible},
    );
  }
}
