import 'package:equatable/equatable.dart';

enum AccessScannerRosterStatus { idle, syncing, synced, failed }

class ScanSuccessNotification extends Equatable {
  const ScanSuccessNotification({
    required this.memberName,
    this.avatarUrl,
    required this.occupancy,
    this.membershipStatus,
  });

  final String memberName;
  final String? avatarUrl;
  final int occupancy;
  final String? membershipStatus;

  @override
  List<Object?> get props =>
      [memberName, avatarUrl, occupancy, membershipStatus];
}

class AccessScannerState extends Equatable {
  const AccessScannerState({
    this.isProcessing = false,
    this.success,
    this.errorKey,
    this.rejectReason,
    this.rosterStatus = AccessScannerRosterStatus.idle,
    this.rosterCount,
    this.rosterErrorKey,
    this.cameraReady = false,
  });

  final bool isProcessing;
  final ScanSuccessNotification? success;
  final String? errorKey;
  final String? rejectReason;
  final AccessScannerRosterStatus rosterStatus;
  final int? rosterCount;
  final String? rosterErrorKey;
  final bool cameraReady;

  AccessScannerState copyWith({
    bool? isProcessing,
    ScanSuccessNotification? success,
    bool clearSuccess = false,
    String? errorKey,
    String? rejectReason,
    bool clearError = false,
    AccessScannerRosterStatus? rosterStatus,
    int? rosterCount,
    String? rosterErrorKey,
    bool clearRosterError = false,
    bool? cameraReady,
  }) {
    return AccessScannerState(
      isProcessing: isProcessing ?? this.isProcessing,
      success: clearSuccess ? null : (success ?? this.success),
      errorKey: clearError ? null : (errorKey ?? this.errorKey),
      rejectReason: clearError ? null : (rejectReason ?? this.rejectReason),
      rosterStatus: rosterStatus ?? this.rosterStatus,
      rosterCount: rosterCount ?? this.rosterCount,
      rosterErrorKey: clearRosterError
          ? null
          : (rosterErrorKey ?? this.rosterErrorKey),
      cameraReady: cameraReady ?? this.cameraReady,
    );
  }

  @override
  List<Object?> get props => [
    isProcessing,
    success,
    errorKey,
    rejectReason,
    rosterStatus,
    rosterCount,
    rosterErrorKey,
    cameraReady,
  ];
}
