import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fithub_portal_admin/core/crypto/qr_signature_validator.dart';
import 'package:fithub_portal_admin/core/database/app_database.dart';
import 'package:fithub_portal_admin/features/scan/data/repositories/scan_repository.dart';

void main() {
  late AppDatabase database;
  late ScanRepository scanRepository;
  const tenantId = '11111111-1111-1111-1111-111111111111';
  const athleteId = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
  const salt = 'demo-salt-001';

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    await database.upsertGymCache(
      LocalGymCacheCompanion.insert(
        tenantId: tenantId,
        name: 'Pulse Downtown',
        currentOccupancy: const Value(42),
        capacityLimit: 120,
      ),
    );
    await database
        .into(database.localMembers)
        .insert(
          LocalMembersCompanion.insert(
            id: athleteId,
            tenantId: tenantId,
            fullName: 'Sara Al-Fares',
            cryptoSalt: salt,
            createdAt: DateTime.utc(2026, 1, 1),
          ),
        );
    scanRepository = ScanRepository(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  group('QrSignatureValidator', () {
    test('accepts valid payload within 30 second window', () {
      const validator = QrSignatureValidator();
      final now = DateTime.utc(2026, 7, 16, 12, 0, 10);
      final timestamp = DateTime.utc(2026, 7, 16, 12, 0, 0);
      final signature = validator.sign(
        athleteId: athleteId,
        timestampSeconds: timestamp.millisecondsSinceEpoch ~/ 1000,
        salt: salt,
      );
      final payload = jsonEncode({
        'athlete_id': athleteId,
        'timestamp': timestamp.millisecondsSinceEpoch ~/ 1000,
        'signature': signature,
      });

      final result = validator.validate(
        rawPayload: payload,
        cryptoSalt: salt,
        now: now,
      );

      expect(result.isValid, isTrue);
      expect(result.athleteId, athleteId);
    });

    test('rejects expired payload', () {
      const validator = QrSignatureValidator();
      final now = DateTime.utc(2026, 7, 16, 12, 1, 0);
      final timestamp = DateTime.utc(2026, 7, 16, 12, 0, 0);
      final signature = validator.sign(
        athleteId: athleteId,
        timestampSeconds: timestamp.millisecondsSinceEpoch ~/ 1000,
        salt: salt,
      );
      final payload = jsonEncode({
        'athlete_id': athleteId,
        'timestamp': timestamp.millisecondsSinceEpoch ~/ 1000,
        'signature': signature,
      });

      final result = validator.validate(
        rawPayload: payload,
        cryptoSalt: salt,
        now: now,
      );

      expect(result.isValid, isFalse);
    });

    test('accepts Flutter-web JSON where timestamp is a double', () {
      const validator = QrSignatureValidator();
      final now = DateTime.utc(2026, 7, 16, 12, 0, 10);
      final timestampSeconds =
          DateTime.utc(2026, 7, 16, 12, 0, 0).millisecondsSinceEpoch ~/ 1000;
      final signature = validator.sign(
        athleteId: athleteId,
        timestampSeconds: timestampSeconds,
        salt: salt,
      );
      final payload =
          '{"athlete_id":"$athleteId","timestamp":$timestampSeconds.0,'
          '"signature":"$signature"}';

      final result = validator.validate(
        rawPayload: payload,
        cryptoSalt: salt,
        now: now,
      );

      expect(result.isValid, isTrue);
      expect(result.athleteId, athleteId);
    });

    test('accepts athlete clock up to 5 seconds ahead of portal', () {
      const validator = QrSignatureValidator();
      final issued = DateTime.utc(2026, 7, 16, 12, 0, 3);
      final portalNow = DateTime.utc(2026, 7, 16, 12, 0, 0);
      final timestampSeconds = issued.millisecondsSinceEpoch ~/ 1000;
      final signature = validator.sign(
        athleteId: athleteId,
        timestampSeconds: timestampSeconds,
        salt: salt,
      );
      final payload = jsonEncode({
        'athlete_id': athleteId,
        'timestamp': timestampSeconds,
        'signature': signature,
      });

      final result = validator.validate(
        rawPayload: payload,
        cryptoSalt: salt,
        now: portalNow,
      );

      expect(result.isValid, isTrue);
    });

    test('accepts token up to 5 seconds past the 30s lifetime', () {
      const validator = QrSignatureValidator();
      final now = DateTime.utc(2026, 7, 16, 12, 0, 34);
      final timestamp = DateTime.utc(2026, 7, 16, 12, 0, 0);
      final signature = validator.sign(
        athleteId: athleteId,
        timestampSeconds: timestamp.millisecondsSinceEpoch ~/ 1000,
        salt: salt,
      );
      final payload = jsonEncode({
        'athlete_id': athleteId,
        'timestamp': timestamp.millisecondsSinceEpoch ~/ 1000,
        'signature': signature,
      });

      final result = validator.validate(
        rawPayload: payload,
        cryptoSalt: salt,
        now: now,
      );

      expect(result.isValid, isTrue);
    });
  });

  group('Offline scan flow (airplane mode simulation)', () {
    test('records attendance locally and increments occupancy', () async {
      const validator = QrSignatureValidator();
      final now = DateTime.utc(2026, 7, 16, 12, 0, 5);
      final timestamp = DateTime.utc(2026, 7, 16, 12, 0, 0);
      final signature = validator.sign(
        athleteId: athleteId,
        timestampSeconds: timestamp.millisecondsSinceEpoch ~/ 1000,
        salt: salt,
      );
      final payload = jsonEncode({
        'athlete_id': athleteId,
        'timestamp': timestamp.millisecondsSinceEpoch ~/ 1000,
        'signature': signature,
      });

      final result = await scanRepository.processOfflineScan(
        tenantId: tenantId,
        rawPayload: payload,
        now: now,
      );

      expect(result.isApproved, isTrue);
      expect(result.occupancy, 43);

      final pending = await database.pendingAttendance();
      expect(pending, hasLength(1));
      expect(pending.first.isSynced, isFalse);
      expect(pending.first.athleteId, athleteId);

      final gym = await database.gymForTenant(tenantId);
      expect(gym?.currentOccupancy, 43);
    });

    test(
      'second scan checks out open visit and decrements occupancy',
      () async {
        const validator = QrSignatureValidator();
        final firstNow = DateTime.utc(2026, 7, 16, 12, 0, 5);
        final secondNow = DateTime.utc(2026, 7, 16, 18, 30, 0);
        final timestamp = DateTime.utc(2026, 7, 16, 12, 0, 0);
        final signature = validator.sign(
          athleteId: athleteId,
          timestampSeconds: timestamp.millisecondsSinceEpoch ~/ 1000,
          salt: salt,
        );
        final payload = jsonEncode({
          'athlete_id': athleteId,
          'timestamp': timestamp.millisecondsSinceEpoch ~/ 1000,
          'signature': signature,
        });

        final first = await scanRepository.processOfflineScan(
          tenantId: tenantId,
          rawPayload: payload,
          now: firstNow,
        );
        expect(first.isApproved, isTrue);

        final secondTs = DateTime.utc(2026, 7, 16, 18, 30, 0);
        final secondSig = validator.sign(
          athleteId: athleteId,
          timestampSeconds: secondTs.millisecondsSinceEpoch ~/ 1000,
          salt: salt,
        );
        final secondPayload = jsonEncode({
          'athlete_id': athleteId,
          'timestamp': secondTs.millisecondsSinceEpoch ~/ 1000,
          'signature': secondSig,
        });

        final second = await scanRepository.processOfflineScan(
          tenantId: tenantId,
          rawPayload: secondPayload,
          now: secondNow,
        );

        expect(second.isApproved, isTrue);
        expect(second.event, 'CHECK_OUT');
        final pending = await database.pendingAttendance();
        expect(pending, hasLength(1));
        expect(pending.first.checkedOutAt, isNot(null));
        final gym = await database.gymForTenant(tenantId);
        expect(gym?.currentOccupancy, 42);
      },
    );
  });
}
