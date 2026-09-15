import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Validates dynamic QR payloads per FEAT-01 AC2.
class QrSignatureValidator {
  const QrSignatureValidator({
    this.tokenLifetime = const Duration(seconds: 30),
  });

  final Duration tokenLifetime;

  /// Expected JSON keys: `athlete_id`, `timestamp`, `signature`.
  QrValidationResult validate({
    required String rawPayload,
    required String cryptoSalt,
    DateTime? now,
  }) {
    final clock = now ?? DateTime.now().toUtc();
    try {
      final decoded = jsonDecode(rawPayload);
      final payload = _asStringKeyedMap(decoded);
      if (payload == null) {
        return const QrValidationResult.invalid('Malformed QR payload.');
      }

      final athleteId = payload['athlete_id']?.toString();
      final timestamp = payload['timestamp'];
      final signature = payload['signature']?.toString();

      if (athleteId == null ||
          athleteId.isEmpty ||
          timestamp == null ||
          signature == null ||
          signature.isEmpty) {
        return const QrValidationResult.invalid('Missing QR fields.');
      }

      final issuedAt = _parseTimestamp(timestamp);
      if (issuedAt == null) {
        return const QrValidationResult.invalid('Invalid timestamp.');
      }

      final age = clock.difference(issuedAt);
      // Flutter web / device clocks can be a few seconds apart. Reject only
      // tokens issued more than 5s in the future, or older than lifetime.
      if (age > tokenLifetime || age < const Duration(seconds: -5)) {
        return const QrValidationResult.invalid('QR token expired.');
      }

      final expected = _sign(
        athleteId: athleteId,
        timestamp: issuedAt.millisecondsSinceEpoch ~/ 1000,
        salt: cryptoSalt,
      );

      if (expected != signature.toLowerCase()) {
        return const QrValidationResult.invalid('Signature mismatch.');
      }

      return QrValidationResult.valid(athleteId: athleteId, issuedAt: issuedAt);
    } on FormatException {
      return const QrValidationResult.invalid('Invalid JSON payload.');
    } catch (_) {
      return const QrValidationResult.invalid('Malformed QR payload.');
    }
  }

  String sign({
    required String athleteId,
    required int timestampSeconds,
    required String salt,
  }) {
    return _sign(athleteId: athleteId, timestamp: timestampSeconds, salt: salt);
  }

  static String _sign({
    required String athleteId,
    required int timestamp,
    required String salt,
  }) {
    final material = '$athleteId:$timestamp:$salt';
    return sha256.convert(utf8.encode(material)).toString();
  }

  /// Flutter web `jsonDecode` yields [Map] that may not be `Map<String, dynamic>`.
  static Map<String, dynamic>? _asStringKeyedMap(Object? decoded) {
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) {
      return {
        for (final entry in decoded.entries) entry.key.toString(): entry.value,
      };
    }
    return null;
  }

  /// Flutter web `jsonDecode` yields [num] (often [double]) for JSON numbers.
  static DateTime? _parseTimestamp(Object? value) {
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(
        value.toInt() * 1000,
        isUtc: true,
      );
    }
    if (value is String) {
      final parsed = num.tryParse(value)?.toInt();
      if (parsed == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(parsed * 1000, isUtc: true);
    }
    return null;
  }
}

class QrValidationResult {
  const QrValidationResult._({
    required this.isValid,
    this.athleteId,
    this.issuedAt,
    this.reason,
  });

  const QrValidationResult.valid({
    required String athleteId,
    required DateTime issuedAt,
  }) : this._(isValid: true, athleteId: athleteId, issuedAt: issuedAt);

  const QrValidationResult.invalid(String reason)
    : this._(isValid: false, reason: reason);

  final bool isValid;
  final String? athleteId;
  final DateTime? issuedAt;
  final String? reason;
}
