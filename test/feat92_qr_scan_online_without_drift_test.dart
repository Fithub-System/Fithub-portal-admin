import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fithub_portal_admin/core/crypto/qr_signature_validator.dart';
import 'package:fithub_portal_admin/core/database/app_database.dart';
import 'package:fithub_portal_admin/features/access_scanner/domain/entities/member_roster_entry.dart';
import 'package:fithub_portal_admin/features/access_scanner/domain/repositories/member_roster_repository.dart';
import 'package:fithub_portal_admin/features/access_scanner/domain/use_cases/process_qr_scan_use_case.dart';
import 'package:fithub_portal_admin/features/scan/data/data_sources/remote/toggle_gym_attendance_remote_data_source.dart';
import 'package:fithub_portal_admin/features/scan/data/repositories/scan_repository.dart';

class _MockToggle extends Mock implements ToggleGymAttendanceRemoteDataSource {}

class _MockRoster extends Mock implements MemberRosterRepository {}

void main() {
  late AppDatabase database;
  late ScanRepository scanRepository;
  late _MockToggle toggle;
  late _MockRoster roster;

  const tenantId = '11111111-1111-1111-1111-111111111111';
  const athleteId = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
  const salt = 'live-salt-abc';

  final rosterEntry = MemberRosterEntry(
    id: athleteId,
    fullName: 'Sara Al-Fares',
    powerScore: 100,
    cryptoSalt: salt,
    createdAt: DateTime.utc(2026, 1, 1),
    membershipStatus: 'active',
  );

  String validPayload({DateTime? now}) {
    const validator = QrSignatureValidator();
    final clock = (now ?? DateTime.now()).toUtc();
    final timestampSeconds = clock.millisecondsSinceEpoch ~/ 1000;
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

  ProcessQrScanUseCase buildUseCase() {
    return ProcessQrScanUseCase(
      scanRepository,
      toggleAttendance: toggle,
      memberRoster: roster,
    );
  }

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    scanRepository = ScanRepository(database: database);
    toggle = _MockToggle();
    roster = _MockRoster();
    when(
      () => roster.listCachedMembers(tenantId: any(named: 'tenantId')),
    ).thenAnswer((_) async => [rosterEntry]);
    when(
      () => roster.syncRoster(tenantId: any(named: 'tenantId')),
    ).thenAnswer((_) async => 1);
    when(
      () => toggle.toggle(athleteId, scannedVia: any(named: 'scannedVia')),
    ).thenAnswer(
      (_) async => const GymAttendanceToggleResult(
        visitId: 'visit-1',
        event: 'CHECK_IN',
        occupancy: 4,
        capacityLimit: 40,
        memberName: 'Sara Al-Fares',
        membershipStatus: 'active',
      ),
    );
  });

  tearDown(() async {
    try {
      await database.close();
    } catch (_) {}
  });

  test('online check-in uses roster salt when Drift cache is empty', () async {
    final result = await buildUseCase()(
      tenantId: tenantId,
      rawPayload: validPayload(),
      online: true,
    );

    expect(result.isApproved, isTrue);
    expect(result.event, 'CHECK_IN');
    expect(result.occupancy, 4);
    expect(result.memberName, 'Sara Al-Fares');
    verify(
      () => toggle.toggle(athleteId, scannedVia: any(named: 'scannedVia')),
    ).called(1);
  });

  test('online check-in succeeds when Drift wasm cache is closed', () async {
    await database.close();

    final result = await buildUseCase()(
      tenantId: tenantId,
      rawPayload: validPayload(),
      online: true,
    );

    expect(result.isApproved, isTrue);
    expect(result.event, 'CHECK_IN');
    verify(
      () => toggle.toggle(athleteId, scannedVia: any(named: 'scannedVia')),
    ).called(1);
  });

  test('placeholder Drift salt does not HMAC-block roster salt', () async {
    await database
        .into(database.localMembers)
        .insert(
          LocalMembersCompanion.insert(
            id: athleteId,
            tenantId: tenantId,
            fullName: 'Sara Al-Fares',
            cryptoSalt: ProcessQrScanUseCase.placeholderSalt,
            createdAt: DateTime.utc(2026, 1, 1),
          ),
        );

    final result = await buildUseCase()(
      tenantId: tenantId,
      rawPayload: validPayload(),
      online: true,
    );

    expect(result.isApproved, isTrue);
    verify(
      () => toggle.toggle(athleteId, scannedVia: any(named: 'scannedVia')),
    ).called(1);
  });

  test('signature mismatch never calls toggle', () async {
    const validator = QrSignatureValidator();
    final timestampSeconds =
        DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    final payload = jsonEncode({
      'athlete_id': athleteId,
      'timestamp': timestampSeconds,
      'signature': validator.sign(
        athleteId: athleteId,
        timestampSeconds: timestampSeconds,
        salt: 'wrong-salt',
      ),
    });

    final result = await buildUseCase()(
      tenantId: tenantId,
      rawPayload: payload,
      online: true,
    );

    expect(result.isApproved, isFalse);
    expect(result.reason, 'Signature mismatch.');
    verifyNever(
      () => toggle.toggle(athleteId, scannedVia: any(named: 'scannedVia')),
    );
  });

  test('RPC not_member is surfaced instead of generic scan failed', () async {
    when(
      () => toggle.toggle(athleteId, scannedVia: any(named: 'scannedVia')),
    ).thenThrow(
      const GymAttendanceToggleFailure(
        'not_member',
        message: 'feat92_athlete_not_member',
      ),
    );

    final result = await buildUseCase()(
      tenantId: tenantId,
      rawPayload: validPayload(),
      online: true,
    );

    expect(result.isApproved, isFalse);
    expect(result.reason, 'Athlete is not a member of this gym.');
  });

  test('camera wrapping around JSON still decodes athlete id', () {
    final payload = validPayload();
    final wrapped = 'garbage $payload trailing';
    expect(scanRepository.decodeAthleteId(wrapped), athleteId);
    expect(QrSignatureValidator.extractJsonObject(wrapped), payload);
  });
}
