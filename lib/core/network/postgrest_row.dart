/// Defensive PostgREST JSON helpers for Flutter web.
///
/// Browser `jsonDecode` often yields `Map<dynamic, dynamic>` and `num` instead
/// of `Map<String, dynamic>` / `int`. Casting those rows throws a TypeError
/// that KPI/roster call sites previously swallowed as empty zeros.
Map<String, dynamic> asJsonMap(Object? raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) {
    return raw.map((key, value) => MapEntry(key.toString(), value));
  }
  throw FormatException('PostgREST row is not a JSON object');
}

int asJsonInt(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? fallback;
}

DateTime? parseJsonUtc(Object? raw) {
  if (raw == null) return null;
  if (raw is DateTime) return raw.toUtc();
  final text = raw.toString().trim();
  if (text.isEmpty) return null;
  return DateTime.tryParse(text)?.toUtc();
}
