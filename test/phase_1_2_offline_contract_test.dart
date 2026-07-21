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

    test('soft rejects second check-in same UTC day', () async {
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

      expect(second.isApproved, isFalse);
      expect(second.reason, 'Already checked in today.');
      expect(await database.pendingAttendance(), hasLength(1));
      final gym = await database.gymForTenant(tenantId);
      expect(gym?.currentOccupancy, 43);
    });
  });
}
