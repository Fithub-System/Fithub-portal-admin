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
      if (decoded is! Map<String, dynamic>) {
        return const QrValidationResult.invalid('Malformed QR payload.');
      }

      final athleteId = decoded['athlete_id'] as String?;
      final timestamp = decoded['timestamp'];
      final signature = decoded['signature'] as String?;

      if (athleteId == null || timestamp == null || signature == null) {
        return const QrValidationResult.invalid('Missing QR fields.');
      }

      final issuedAt = _parseTimestamp(timestamp);
      if (issuedAt == null) {
        return const QrValidationResult.invalid('Invalid timestamp.');
      }

      final age = clock.difference(issuedAt);
      if (age.isNegative || age > tokenLifetime) {
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

  static DateTime? _parseTimestamp(Object value) {
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value * 1000, isUtc: true);
    }
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) {
        return DateTime.fromMillisecondsSinceEpoch(parsed * 1000, isUtc: true);
      }
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
