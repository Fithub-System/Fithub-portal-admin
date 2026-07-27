import 'package:equatable/equatable.dart';

enum OfflineSyncStatus { idle, syncing, success, failure }

class OfflineSyncState extends Equatable {
  const OfflineSyncState({
    required this.status,
    this.upsertedCount = 0,
    this.statusMessageKey,
    this.occupancyDenialDetail,
  });

  const OfflineSyncState.idle()
    : status = OfflineSyncStatus.idle,
      upsertedCount = 0,
      statusMessageKey = null,
      occupancyDenialDetail = null;

  final OfflineSyncStatus status;
  final int upsertedCount;

  /// Localized status (e.g. occupancy RLS denial).
  final String? statusMessageKey;
  final String? occupancyDenialDetail;

  OfflineSyncState copyWith({
    OfflineSyncStatus? status,
    int? upsertedCount,
    String? statusMessageKey,
    String? occupancyDenialDetail,
    bool clearStatus = false,
  }) {
    return OfflineSyncState(
      status: status ?? this.status,
      upsertedCount: upsertedCount ?? this.upsertedCount,
      statusMessageKey: clearStatus
          ? null
          : (statusMessageKey ?? this.statusMessageKey),
      occupancyDenialDetail: clearStatus
          ? null
          : (occupancyDenialDetail ?? this.occupancyDenialDetail),
    );
  }

  @override
  List<Object?> get props => [
    status,
    upsertedCount,
    statusMessageKey,
    occupancyDenialDetail,
  ];
}
