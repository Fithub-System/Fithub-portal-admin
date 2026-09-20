import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../memberships/domain/entities/membership_plan.dart';
import '../../staff_invite/domain/entities/staff_role.dart';
import '../data/gym_onboarding_remote.dart';

class GymOnboardingState extends Equatable {
  const GymOnboardingState({
    this.step = 0,
    this.loading = true,
    this.saving = false,
    this.snapshot,
    this.messageKey,
    this.brandName = '',
    this.tradingName = '',
    this.taxId = '',
    this.contactName = '',
    this.contactPhone = '',
    this.contactRole = 'Owner',
    this.branchName = '',
    this.branchAddress = '',
    this.lat = 30.0444,
    this.lng = 31.2357,
    this.capacity = 80,
    this.amenityTags = const ['parking', 'ac'],
    this.staffSize = 5,
    this.planName = '',
    this.planDays = 30,
    this.planPriceEgp = 1500,
    this.passRoaming = false,
  });

  final int step;
  final bool loading;
  final bool saving;
  final GymOnboardingSnapshot? snapshot;
  final String? messageKey;
  final String brandName;
  final String tradingName;
  final String taxId;
  final String contactName;
  final String contactPhone;
  final String contactRole;
  final String branchName;
  final String branchAddress;
  final double lat;
  final double lng;
  final int capacity;
  final List<String> amenityTags;
  final int staffSize;
  final String planName;
  final int planDays;
  final int planPriceEgp;
  final bool passRoaming;

  int get score => snapshot?.score ?? 0;
  bool get canPublish => snapshot?.canPublish ?? false;

  GymOnboardingState copyWith({
    int? step,
    bool? loading,
    bool? saving,
    GymOnboardingSnapshot? snapshot,
    String? messageKey,
    bool clearMessage = false,
    String? brandName,
    String? tradingName,
    String? taxId,
    String? contactName,
    String? contactPhone,
    String? contactRole,
    String? branchName,
    String? branchAddress,
    double? lat,
    double? lng,
    int? capacity,
    List<String>? amenityTags,
    int? staffSize,
    String? planName,
    int? planDays,
    int? planPriceEgp,
    bool? passRoaming,
  }) {
    return GymOnboardingState(
      step: step ?? this.step,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      snapshot: snapshot ?? this.snapshot,
      messageKey: clearMessage ? null : (messageKey ?? this.messageKey),
      brandName: brandName ?? this.brandName,
      tradingName: tradingName ?? this.tradingName,
      taxId: taxId ?? this.taxId,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      contactRole: contactRole ?? this.contactRole,
      branchName: branchName ?? this.branchName,
      branchAddress: branchAddress ?? this.branchAddress,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      capacity: capacity ?? this.capacity,
      amenityTags: amenityTags ?? this.amenityTags,
      staffSize: staffSize ?? this.staffSize,
      planName: planName ?? this.planName,
      planDays: planDays ?? this.planDays,
      planPriceEgp: planPriceEgp ?? this.planPriceEgp,
      passRoaming: passRoaming ?? this.passRoaming,
    );
  }

  @override
  List<Object?> get props => [
    step,
    loading,
    saving,
    snapshot,
    messageKey,
    brandName,
    tradingName,
    taxId,
    contactName,
    contactPhone,
    contactRole,
    branchName,
    branchAddress,
    lat,
    lng,
    capacity,
    amenityTags,
    staffSize,
    planName,
    planDays,
    planPriceEgp,
    passRoaming,
  ];
}

class GymOnboardingCubit extends Cubit<GymOnboardingState> {
  GymOnboardingCubit({required GymOnboardingRemote remote})
    : _remote = remote,
      super(const GymOnboardingState());

  final GymOnboardingRemote _remote;

  static Map<String, dynamic> defaultHours() {
    const days = ['sat', 'sun', 'mon', 'tue', 'wed', 'thu', 'fri'];
    return {
      for (final d in days)
        d: {'open': '06:00', 'close': '23:00', 'closed': false},
    };
  }

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearMessage: true));
    try {
      final snap = await _remote.load().timeout(const Duration(seconds: 15));
      final gym = snap.gym;
      final branch = snap.branches.isNotEmpty ? snap.branches.first : null;
      final tags = branch == null
          ? state.amenityTags
          : (branch['tags'] as List? ?? []).map((e) => e.toString()).toList();
      emit(
        state.copyWith(
          loading: false,
          snapshot: snap,
          brandName: gym['name']?.toString() ?? '',
          tradingName: gym['trading_name']?.toString() ?? '',
          taxId: gym['tax_id']?.toString() ?? '',
          contactName: gym['contact_name']?.toString() ?? '',
          contactPhone: gym['contact_phone_e164']?.toString() ?? '',
          contactRole: gym['contact_role']?.toString() ?? 'Owner',
          staffSize: (gym['estimated_staff_size'] as num?)?.toInt() ?? 5,
          branchName: branch?['name']?.toString() ?? '',
          branchAddress: branch?['address']?.toString() ?? '',
          lat: (branch?['lat'] as num?)?.toDouble() ?? 30.0444,
          lng: (branch?['lng'] as num?)?.toDouble() ?? 31.2357,
          capacity: (branch?['capacity_ceiling'] as num?)?.toInt() ?? 80,
          amenityTags: tags.isEmpty ? const ['parking', 'ac'] : tags,
        ),
      );
    } catch (_) {
      emit(state.copyWith(loading: false, messageKey: 'onboarding.error.load'));
    }
  }

  void setStep(int step) => emit(state.copyWith(step: step.clamp(0, 4)));

  void patch(GymOnboardingState next) => emit(next);

  Future<bool> saveBrand() async {
    if (state.brandName.trim().isEmpty) {
      emit(state.copyWith(messageKey: 'onboarding.error.brand_name'));
      return false;
    }
    emit(state.copyWith(saving: true, clearMessage: true));
    try {
      await _remote.saveProfile(
        name: state.brandName.trim(),
        tradingName: state.tradingName.trim(),
        taxId: state.taxId.trim(),
        contactName: state.contactName.trim(),
        contactPhone: state.contactPhone.trim(),
        contactRole: state.contactRole,
        estimatedStaffSize: state.staffSize,
      );
      await load();
      emit(state.copyWith(saving: false, step: 1));
      return true;
    } catch (_) {
      emit(state.copyWith(saving: false, messageKey: 'onboarding.error.save'));
      return false;
    }
  }

  Future<bool> saveBranch() async {
    if (state.branchName.trim().isEmpty || state.branchAddress.trim().isEmpty) {
      emit(state.copyWith(messageKey: 'onboarding.error.branch'));
      return false;
    }
    emit(state.copyWith(saving: true, clearMessage: true));
    try {
      final existingId = state.snapshot?.branches.isNotEmpty == true
          ? state.snapshot!.branches.first['id']?.toString()
          : null;
      final id = await _remote.saveBranch(
        id: existingId,
        name: state.branchName.trim(),
        address: state.branchAddress.trim(),
        lat: state.lat,
        lng: state.lng,
        hours: defaultHours(),
        capacity: state.capacity,
        photoUrls: const [GymOnboardingRemote.placeholderPhoto],
      );
      await _remote.setFacilities(id, state.amenityTags);
      await load();
      emit(state.copyWith(saving: false, step: 2));
      return true;
    } catch (_) {
      emit(state.copyWith(saving: false, messageKey: 'onboarding.error.save'));
      return false;
    }
  }

  Future<void> skipStaff() async {
    emit(state.copyWith(step: 3));
  }

  Future<void> inviteStaff({
    required String email,
    required String name,
    required StaffRole role,
  }) async {
    emit(state.copyWith(saving: true, clearMessage: true));
    try {
      await _remote.saveProfile(
        name: state.brandName.trim().isEmpty
            ? (state.snapshot?.gym['name']?.toString() ?? 'Gym')
            : state.brandName.trim(),
        estimatedStaffSize: state.staffSize,
      );
      await _remote.invite(email: email, name: name, role: role);
      emit(state.copyWith(saving: false, messageKey: 'onboarding.staff.sent'));
    } catch (_) {
      emit(
        state.copyWith(saving: false, messageKey: 'onboarding.error.invite'),
      );
    }
  }

  Future<bool> savePlan() async {
    if (state.planName.trim().isEmpty) {
      emit(state.copyWith(messageKey: 'onboarding.error.plan'));
      return false;
    }
    emit(state.copyWith(saving: true, clearMessage: true));
    try {
      await _remote.addPlan(
        name: state.planName.trim(),
        durationDays: state.planDays,
        priceCents: (state.planPriceEgp * 100).round(),
        passKind: state.passRoaming
            ? MembershipPassKind.roaming
            : MembershipPassKind.singleBranch,
      );
      await load();
      emit(state.copyWith(saving: false, step: 4));
      return true;
    } catch (_) {
      emit(state.copyWith(saving: false, messageKey: 'onboarding.error.save'));
      return false;
    }
  }

  Future<bool> publish() async {
    if (!state.canPublish) {
      emit(state.copyWith(messageKey: 'onboarding.error.score'));
      return false;
    }
    emit(state.copyWith(saving: true, clearMessage: true));
    try {
      await _remote.publish(true);
      await load();
      emit(state.copyWith(saving: false, messageKey: 'onboarding.publish.ok'));
      return true;
    } catch (_) {
      emit(
        state.copyWith(saving: false, messageKey: 'onboarding.error.publish'),
      );
      return false;
    }
  }
}
