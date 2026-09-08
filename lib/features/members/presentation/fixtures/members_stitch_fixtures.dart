import '../../../access_scanner/domain/entities/member_roster_entry.dart';

/// Stitch Member Management sample chrome (widget tests / explicit demo only).
///
/// FEAT-59: do **not** mask an empty live roster with [sampleRows] in production.
/// Screen `9b35dd57f15443e99f7e798f6867acb6` — Active Roster sample rows/stats.
abstract final class MembersStitchFixtures {
  static const String eliteTierValue = '124';
  static const String avgXpValue = '68.2';
  static const String activeSessionsValue = '42';
  static const String systemHealthValue = 'Optimal';

  static const int paginationTotalFixture = 1240;
  static const String paginationRangeFixture = '1-10';

  static const String copyright =
      '© 2024 Kinetic Monolith Systems. All Rights Reserved.';

  static final List<MemberRosterEntry> sampleRows = [
    MemberRosterEntry(
      id: 'KM-8821',
      fullName: 'Dominic Russo',
      powerScore: 88,
      cryptoSalt: 'fixture',
      createdAt: DateTime.utc(2024, 1, 1),
      membershipId: 'mem-fixture-1',
      membershipPlanId: 'plan-elite',
      membershipPlanName: 'Elite',
      membershipStatus: 'active',
    ),
    MemberRosterEntry(
      id: 'KM-4521',
      fullName: 'Sarah Miller',
      powerScore: 42,
      cryptoSalt: 'fixture',
      createdAt: DateTime.utc(2024, 1, 2),
      membershipId: 'mem-fixture-2',
      membershipPlanId: 'plan-standard',
      membershipPlanName: 'Standard',
      membershipStatus: 'active',
    ),
    MemberRosterEntry(
      id: 'KM-1092',
      fullName: 'Jason Kang',
      powerScore: 15,
      cryptoSalt: 'fixture',
      createdAt: DateTime.utc(2024, 1, 3),
      membershipId: 'mem-fixture-3',
      membershipPlanId: 'plan-basic',
      membershipPlanName: 'Basic',
      membershipStatus: 'active',
    ),
    MemberRosterEntry(
      id: 'KM-7732',
      fullName: 'Elena Belova',
      powerScore: 94,
      cryptoSalt: 'fixture',
      createdAt: DateTime.utc(2024, 1, 4),
      membershipId: 'mem-fixture-4',
      membershipPlanId: 'plan-elite',
      membershipPlanName: 'Elite',
      membershipStatus: 'active',
    ),
  ];

  /// True when [id] matches Stitch sample chrome member ids.
  static bool isFixtureId(String id) =>
      id == 'KM-8821' ||
      id == 'KM-4521' ||
      id == 'KM-1092' ||
      id == 'KM-7732';
}

/// Plan chip visual kind — FEAT-61: label is always the live plan name;
/// styling is neutral (no Elite/Standard/Basic keyword heuristic).
enum MembersPlanChipKind { named, none }

MembersPlanChipKind membersPlanChipKind(String? planName) {
  if (planName == null || planName.trim().isEmpty) {
    return MembersPlanChipKind.none;
  }
  return MembersPlanChipKind.named;
}

/// Exact live plan name for the roster chip (AC-B1).
String membersPlanChipLabel(String? planName) {
  final name = planName?.trim();
  if (name == null || name.isEmpty) {
    return '—';
  }
  return name;
}

String membersInitials(String fullName) {
  final parts = fullName
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    final s = parts.first;
    return s.length >= 2 ? s.substring(0, 2).toUpperCase() : s.toUpperCase();
  }
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}

String membersDisplayId(MemberRosterEntry member) {
  if (MembersStitchFixtures.isFixtureId(member.id)) {
    return 'ID: ${member.id}';
  }
  final raw = member.id.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
  if (raw.length >= 4) {
    return 'ID: KM-${raw.substring(raw.length - 4).toUpperCase()}';
  }
  return 'ID: ${member.id}';
}
