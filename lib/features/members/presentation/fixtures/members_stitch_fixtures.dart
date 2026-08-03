import '../../../access_scanner/domain/entities/member_roster_entry.dart';

/// Stitch Member Management sample chrome (§4.1 fixtures).
///
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
      membershipPlanName: 'Elite',
      membershipStatus: 'active',
    ),
    MemberRosterEntry(
      id: 'KM-4521',
      fullName: 'Sarah Miller',
      powerScore: 42,
      cryptoSalt: 'fixture',
      createdAt: DateTime.utc(2024, 1, 2),
      membershipPlanName: 'Standard',
      membershipStatus: 'active',
    ),
    MemberRosterEntry(
      id: 'KM-1092',
      fullName: 'Jason Kang',
      powerScore: 15,
      cryptoSalt: 'fixture',
      createdAt: DateTime.utc(2024, 1, 3),
      membershipPlanName: 'Basic',
      membershipStatus: 'active',
    ),
    MemberRosterEntry(
      id: 'KM-7732',
      fullName: 'Elena Belova',
      powerScore: 94,
      cryptoSalt: 'fixture',
      createdAt: DateTime.utc(2024, 1, 4),
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

/// Plan chip visual kind matching Stitch Elite / Standard / Basic.
enum MembersPlanChipKind { elite, standard, basic, unknown }

MembersPlanChipKind membersPlanChipKind(String? planName) {
  if (planName == null || planName.trim().isEmpty) {
    return MembersPlanChipKind.unknown;
  }
  final lower = planName.toLowerCase();
  if (lower.contains('elite') || lower.contains('premium')) {
    return MembersPlanChipKind.elite;
  }
  if (lower.contains('standard') ||
      lower.contains('pro') ||
      lower.contains('monthly')) {
    return MembersPlanChipKind.standard;
  }
  if (lower.contains('basic') || lower.contains('day')) {
    return MembersPlanChipKind.basic;
  }
  // Default mid-tier styling for unknown named plans (avoid bare —).
  return MembersPlanChipKind.standard;
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
