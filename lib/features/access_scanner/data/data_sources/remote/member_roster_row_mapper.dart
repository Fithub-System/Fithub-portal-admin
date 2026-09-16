import '../../../../../core/network/postgrest_row.dart';
import '../../../domain/entities/member_roster_entry.dart';

/// Maps a PostgREST `athletes` object (or gym_members embed) to a roster row.
///
/// Skips incomplete rows instead of failing the whole sync (P0 data blindness).
MemberRosterEntry? mapAthleteRosterRow(Object? raw) {
  try {
    final row = asJsonMap(raw);
    final id = row['id']?.toString().trim() ?? '';
    final fullName = row['full_name']?.toString().trim() ?? '';
    if (id.isEmpty || fullName.isEmpty) return null;

    return MemberRosterEntry(
      id: id,
      fullName: fullName,
      avatarUrl: row['avatar_url']?.toString(),
      powerScore: asJsonInt(row['power_score'], fallback: 100),
      cryptoSalt: row['crypto_salt']?.toString() ?? '',
      createdAt: parseJsonUtc(row['created_at']) ?? DateTime.now().toUtc(),
    );
  } catch (_) {
    return null;
  }
}

/// Unwraps `gym_members.athletes` embed (object or single-element list).
Object? embeddedAthlete(Object? raw) {
  if (raw == null) return null;
  if (raw is List) {
    if (raw.isEmpty) return null;
    return raw.first;
  }
  return raw;
}
