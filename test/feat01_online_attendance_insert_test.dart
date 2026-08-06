import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fithub_portal_admin/core/crypto/qr_signature_validator.dart';
import 'package:fithub_portal_admin/core/database/app_database.dart';
import 'package:fithub_portal_admin/features/access_scanner/domain/use_cases/process_qr_scan_use_case.dart';
import 'package:fithub_portal_admin/features/offline_sync/domain/entities/offline_sync_result.dart';
import 'package:fithub_portal_admin/features/offline_sync/domain/offline_sync_failure.dart';
import 'package:fithub_portal_admin/features/offline_sync/domain/use_cases/offline_sync_use_case.dart';
import 'package:fithub_portal_admin/features/scan/data/repositories/scan_repository.dart';

class _MockSyncPendingAttendance extends Mock
    implements SyncPendingAttendanceUseCase {}

void main() {
  late AppDatabase database;
  late ScanRepository scanRepository;
  late _MockSyncPendingAttendance syncPending;
  const tenantId = '11111111-1111-1111-1111-111111111111';
  const athleteId = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
  const salt = 'demo-salt-001';

  String validPayloadForNow() {
    const validator = QrSignatureValidator();
    final now = DateTime.now().toUtc();
    final timestampSeconds = now.millisecondsSinceEpoch ~/ 1000;
    final signature = validator.sign(
      athleteId: athleteId,
      timestampSeconds: timestampSeconds,
      salt: salt,
    );
    return jsonEncode({
      'athlete_id': athleteId,
      'timestamp': timestampSeconds,
      'signature': signature,
    });
  }

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    await database.upsertGymCache(
      LocalGymCacheCompanion.insert(
        tenantId: tenantId,
        name: 'Pulse Downtown',
        currentOccupancy: const Value(10),
        capacityLimit: 120,
      ),
    );
    await database.into(database.localMembers).insert(
          LocalMembersCompanion.insert(
            id: athleteId,
            tenantId: tenantId,
            fullName: 'Sara Al-Fares',
            cryptoSalt: salt,
            createdAt: DateTime.utc(2026, 1, 1),
          ),
        );
    scanRepository = ScanRepository(database: database);
    syncPending = _MockSyncPendingAttendance();
  });

  tearDown(() async {
    await database.close();
  });

  group('ProcessQrScanUseCase online attendance flush (FEAT-01 / FEAT-09 P0)', () {
    test('online approved scan flushes attendance_logs via sync use case',
        () async {
      when(
        () => syncPending(tenantId: any(named: 'tenantId')),
      ).thenAnswer((_) async => const OfflineSyncResult(upsertedCount: 1));

      final useCase = ProcessQrScanUseCase(
        scanRepository,
        syncPendingAttendance: syncPending,
      );

      final result = await useCase(
        tenantId: tenantId,
        rawPayload: validPayloadForNow(),
        online: true,
      );

      expect(result.isApproved, isTrue);
      expect(result.occupancy, 11);
      verify(() => syncPending(tenantId: tenantId)).called(1);
      expect(await database.pendingAttendance(), hasLength(1));
    });

    test('offline approved scan does not flush to cloud', () async {
      final useCase = ProcessQrScanUseCase(
        scanRepository,
        syncPendingAttendance: syncPending,
      );

      final result = await useCase(
        tenantId: tenantId,
        rawPayload: validPayloadForNow(),
        online: false,
      );

      expect(result.isApproved, isTrue);
      verifyNever(() => syncPending(tenantId: any(named: 'tenantId')));
      expect(await database.pendingAttendance(), hasLength(1));
    });

    test('rejected scan never flushes', () async {
      final useCase = ProcessQrScanUseCase(
        scanRepository,
        syncPendingAttendance: syncPending,
      );

      final result = await useCase(
        tenantId: tenantId,
        rawPayload: '{"athlete_id":"missing"}',
        online: true,
      );

      expect(result.isApproved, isFalse);
      verifyNever(() => syncPending(tenantId: any(named: 'tenantId')));
    });

    test('online flush failure still returns local approval (SafeMode)',
        () async {
      when(
        () => syncPending(tenantId: any(named: 'tenantId')),
      ).thenThrow(const OfflineSyncAttendanceUpsertFailure());

      final useCase = ProcessQrScanUseCase(
        scanRepository,
        syncPendingAttendance: syncPending,
      );

      final result = await useCase(
        tenantId: tenantId,
        rawPayload: validPayloadForNow(),
        online: true,
      );

      expect(result.isApproved, isTrue);
      expect(await database.pendingAttendance(), hasLength(1));
    });

    test('same-day soft reject skips second flush', () async {
      when(
        () => syncPending(tenantId: any(named: 'tenantId')),
      ).thenAnswer((_) async => const OfflineSyncResult(upsertedCount: 1));

      final useCase = ProcessQrScanUseCase(
        scanRepository,
        syncPendingAttendance: syncPending,
      );

      final first = await useCase(
        tenantId: tenantId,
        rawPayload: validPayloadForNow(),
        online: true,
      );
      expect(first.isApproved, isTrue);

      final second = await useCase(
        tenantId: tenantId,
        rawPayload: validPayloadForNow(),
        online: true,
      );
      expect(second.isApproved, isFalse);
      expect(second.reason, 'Already checked in today.');

      verify(() => syncPending(tenantId: tenantId)).called(1);
    });
  });
}
