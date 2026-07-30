part of 'billing_cubit.dart';

enum BillingStatus { initial, loading, ready, failure }

class BillingState extends Equatable {
  const BillingState({
    this.status = BillingStatus.initial,
    this.charges = const [],
    this.busy = false,
    this.messageKey,
    this.freezePausedCount,
  });

  final BillingStatus status;
  final List<MembershipCharge> charges;
  final bool busy;
  final String? messageKey;
  final int? freezePausedCount;

  BillingState copyWith({
    BillingStatus? status,
    List<MembershipCharge>? charges,
    bool? busy,
    String? messageKey,
    int? freezePausedCount,
    bool clearMessage = false,
  }) {
    return BillingState(
      status: status ?? this.status,
      charges: charges ?? this.charges,
      busy: busy ?? this.busy,
      messageKey: clearMessage ? null : (messageKey ?? this.messageKey),
      freezePausedCount: freezePausedCount ?? this.freezePausedCount,
    );
  }

  @override
  List<Object?> get props => [
    status,
    charges,
    busy,
    messageKey,
    freezePausedCount,
  ];
}
