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
    this.lat,
    this.lng,
    this.capacity,
    this.amenityTags = const [],
    this.hoursOpen = '',
    this.hoursClose = '',
    this.photoUrl = '',
    this.staffSize,
    this.planName = '',
    this.planDays,
    this.planPriceEgp,
    this.passRoaming = false,
    this.savedPlans = const [],
  });

  static const Object _absent = Object();

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
  final double? lat;
  final double? lng;
  final int? capacity;
  final List<String> amenityTags;
  final String hoursOpen;
  final String hoursClose;
  final String photoUrl;
  final int? staffSize;
  final String planName;
  final int? planDays;
  final int? planPriceEgp;
  final bool passRoaming;
  final List<MembershipPlan> savedPlans;

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
    Object? lat = _absent,
    Object? lng = _absent,
    Object? capacity = _absent,
    List<String>? amenityTags,
    String? hoursOpen,
    String? hoursClose,
    String? photoUrl,
    Object? staffSize = _absent,
    String? planName,
    Object? planDays = _absent,
    Object? planPriceEgp = _absent,
    bool? passRoaming,
    List<MembershipPlan>? savedPlans,
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
      lat: identical(lat, _absent) ? this.lat : lat as double?,
      lng: identical(lng, _absent) ? this.lng : lng as double?,
      capacity: identical(capacity, _absent) ? this.capacity : capacity as int?,
      amenityTags: amenityTags ?? this.amenityTags,
      hoursOpen: hoursOpen ?? this.hoursOpen,
      hoursClose: hoursClose ?? this.hoursClose,
      photoUrl: photoUrl ?? this.photoUrl,
      staffSize: identical(staffSize, _absent)
          ? this.staffSize
          : staffSize as int?,
      planName: planName ?? this.planName,
      planDays: identical(planDays, _absent) ? this.planDays : planDays as int?,
      planPriceEgp: identical(planPriceEgp, _absent)
          ? this.planPriceEgp
          : planPriceEgp as int?,
      passRoaming: passRoaming ?? this.passRoaming,
      savedPlans: savedPlans ?? this.savedPlans,
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
    hoursOpen,
    hoursClose,
    photoUrl,
    staffSize,
    planName,
    planDays,
    planPriceEgp,
    passRoaming,
    savedPlans,
  ];
}

class GymOnboardingCubit extends Cubit<GymOnboardingState> {
  GymOnboardingCubit({required GymOnboardingRemote remote})
    : _remote = remote,
      super(const GymOnboardingState());

  final GymOnboardingRemote _remote;

  static const _weekDays = ['sat', 'sun', 'mon', 'tue', 'wed', 'thu', 'fri'];

  /// Hours the Admin typed — empty map when they have not set open/close.
  static Map<String, dynamic> hoursFrom({
    required String open,
    required String close,
  }) {
    final o = open.trim();
    final c = close.trim();
    if (o.isEmpty || c.isEmpty) return {};
    return {
      for (final d in _weekDays) d: {'open': o, 'close': c, 'closed': false},
    };
  }

  static bool isLivePhoto(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return false;
    if (trimmed == GymOnboardingRemote.placeholderPhoto) return false;
    return !trimmed.contains('placehold.co');
  }

  static ({String open, String close}) hoursFromSnapshot(Map? branch) {
    final raw = branch?['hours'];
    if (raw is! Map) return (open: '', close: '');
    for (final value in raw.values) {
      if (value is! Map) continue;
      if (value['closed'] == true) continue;
      final open = value['open']?.toString().trim() ?? '';
      final close = value['close']?.toString().trim() ?? '';
      if (open.isEmpty || close.isEmpty) continue;
      return (open: open, close: close);
    }
    return (open: '', close: '');
  }

  Future<void> load({bool silent = false}) async {
    if (!silent) {
      emit(state.copyWith(loading: true, clearMessage: true));
    }
    try {
      final snap = await _remote.load().timeout(const Duration(seconds: 15));
      var plans = const <MembershipPlan>[];
      try {
        plans = await _remote.loadPlans().timeout(const Duration(seconds: 15));
      } catch (_) {
        plans = const [];
      }
      final gym = snap.gym;
      final branch = snap.branches.isNotEmpty ? snap.branches.first : null;
      final tags = (branch?['tags'] as List? ?? [])
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList();
      final photos = (branch?['photo_urls'] as List? ?? [])
          .map((e) => e.toString())
          .where(isLivePhoto)
          .toList();
      final hours = hoursFromSnapshot(branch);
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
          staffSize: (gym['estimated_staff_size'] as num?)?.toInt(),
          branchName: branch?['name']?.toString() ?? '',
          branchAddress: branch?['address']?.toString() ?? '',
          lat: (branch?['lat'] as num?)?.toDouble(),
          lng: (branch?['lng'] as num?)?.toDouble(),
          capacity: (branch?['capacity_ceiling'] as num?)?.toInt(),
          amenityTags: tags,
          hoursOpen: hours.open,
          hoursClose: hours.close,
          photoUrl: photos.isEmpty ? '' : photos.first,
          savedPlans: plans.where((plan) => plan.isActive).toList(),
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
    final capacity = state.capacity;
    if (capacity == null || capacity <= 0) {
      emit(state.copyWith(messageKey: 'onboarding.error.branch'));
      return false;
    }
    emit(state.copyWith(saving: true, clearMessage: true));
    try {
      final existingId = state.snapshot?.branches.isNotEmpty == true
          ? state.snapshot!.branches.first['id']?.toString()
          : null;
      final photo = state.photoUrl.trim();
      final id = await _remote.saveBranch(
        id: existingId,
        name: state.branchName.trim(),
        address: state.branchAddress.trim(),
        lat: state.lat,
        lng: state.lng,
        hours: hoursFrom(open: state.hoursOpen, close: state.hoursClose),
        capacity: capacity,
        photoUrls: isLivePhoto(photo) ? [photo] : const [],
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

  Future<bool> savePlan({bool advance = false}) async {
    final days = state.planDays;
    final price = state.planPriceEgp;
    if (state.planName.trim().isEmpty ||
        days == null ||
        days <= 0 ||
        price == null ||
        price <= 0) {
      emit(state.copyWith(messageKey: 'onboarding.error.plan'));
      return false;
    }
    emit(state.copyWith(saving: true, clearMessage: true));
    try {
      await _remote.addPlan(
        name: state.planName.trim(),
        durationDays: days,
        priceCents: (price * 100).round(),
        passKind: state.passRoaming
            ? MembershipPassKind.roaming
            : MembershipPassKind.singleBranch,
      );
      await load(silent: true);
      emit(
        state.copyWith(
          saving: false,
          step: advance ? 4 : 3,
          planName: '',
          planDays: null,
          planPriceEgp: null,
          passRoaming: false,
          messageKey: 'onboarding.step4.added',
        ),
      );
      return true;
    } catch (_) {
      emit(state.copyWith(saving: false, messageKey: 'onboarding.error.save'));
      return false;
    }
  }

  bool get _hasPlanDraft =>
      state.planName.trim().isNotEmpty ||
      state.planDays != null ||
      state.planPriceEgp != null;

  Future<bool> continueToReview() async {
    if (_hasPlanDraft) {
      return savePlan(advance: true);
    }
    if (state.savedPlans.isEmpty) {
      emit(state.copyWith(messageKey: 'onboarding.error.plan'));
      return false;
    }
    emit(state.copyWith(step: 4, clearMessage: true));
    return true;
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
