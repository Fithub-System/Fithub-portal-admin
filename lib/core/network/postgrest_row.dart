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

/// Walks a PostgREST array; skips entries that are not JSON objects.
List<Map<String, dynamic>> asJsonMapList(Object? raw) {
  if (raw == null) return const [];
  if (raw is! List) {
    throw FormatException('PostgREST list is not a JSON array');
  }
  final rows = <Map<String, dynamic>>[];
  for (final item in raw) {
    try {
      rows.add(asJsonMap(item));
    } catch (_) {}
  }
  return rows;
}

String? jsonStringOrNull(Object? value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

bool jsonBool(Object? value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value?.toString().toLowerCase().trim();
  if (text == 'true' || text == 't' || text == '1') return true;
  if (text == 'false' || text == 'f' || text == '0') return false;
  return fallback;
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
