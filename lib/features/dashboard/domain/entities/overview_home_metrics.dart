import 'overview_expiring_row.dart';

/// FEAT-60 — live Home Overview KPIs (honest empty/zero).
///
/// Day windows use **UTC** for `attendance_logs.checked_in_at` and
/// `membership_charges.paid_at` (matches Backend same-day unique index).
class OverviewHomeMetrics {
  const OverviewHomeMetrics({
    required this.membersCount,
    required this.checkInsToday,
    required this.revenueTodayCents,
    required this.revenueCurrency,
    required this.expiringSoon,
  });

  /// Active gym roster count after cloud honesty (cached post-sync).
  final int membersCount;

  /// `attendance_logs` rows for the tenant with `checked_in_at` on UTC today.
  final int checkInsToday;

  /// Sum of `membership_charges.amount_cents` with `status=paid` and
  /// `paid_at` on UTC today. Zero when none.
  final int revenueTodayCents;

  /// Currency from first paid charge today, else gym default `EGP`.
  final String revenueCurrency;

  /// Active memberships with `ends_at` within [expiringSoonWindow].
  final List<OverviewExpiringRow> expiringSoon;

  /// Configurable 48h window (FSD soft lock).
  static const Duration expiringSoonWindow = Duration(hours: 48);

  static const String defaultCurrency = 'EGP';

  /// Formats revenue for Daily Yield — currency code + grouped major units.
  ///
  /// Documented format: `{CURRENCY} {amount}` (e.g. `EGP 0`, `EGP 1,250.00`).
  /// Does not invent `$` when currency is EGP.
  String get revenueAmountLabel {
    final major = revenueTodayCents / 100.0;
    final formatted = _formatMajor(major);
    return '$revenueCurrency $formatted';
  }

  String get membersCountLabel => _formatInt(membersCount);

  String get checkInsTodayLabel => _formatInt(checkInsToday);

  static String _formatInt(int value) {
    final raw = value.toString();
    final buf = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      final fromEnd = raw.length - i;
      buf.write(raw[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buf.write(',');
    }
    return buf.toString();
  }

  static String _formatMajor(double major) {
    if (major == major.roundToDouble()) {
      return _formatInt(major.round());
    }
    final fixed = major.toStringAsFixed(2);
    final parts = fixed.split('.');
    return '${_formatInt(int.parse(parts[0]))}.${parts[1]}';
  }
}
