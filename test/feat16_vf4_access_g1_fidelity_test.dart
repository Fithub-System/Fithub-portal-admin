import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fithub_portal_admin/config/theme/kinetic_tokens.dart';
import 'package:fithub_portal_admin/features/access_scanner/domain/repositories/member_roster_repository.dart';
import 'package:fithub_portal_admin/features/access_scanner/domain/use_cases/process_qr_scan_use_case.dart';
import 'package:fithub_portal_admin/features/access_scanner/domain/use_cases/sync_member_roster_use_case.dart';
import 'package:fithub_portal_admin/features/access_scanner/presentation/cubit/access_scanner_cubit.dart';
import 'package:fithub_portal_admin/features/access_scanner/presentation/cubit/access_scanner_state.dart';
import 'package:fithub_portal_admin/features/access_scanner/presentation/fixtures/access_gate_stitch_fixtures.dart';
import 'package:fithub_portal_admin/features/access_scanner/presentation/widgets/check_in_gate_layout.dart';
import 'package:fithub_portal_admin/features/home/presentation/pages/portal_shell_destinations.dart';
import 'package:fithub_portal_admin/features/home/presentation/widgets/access_scanner_focus_host.dart';
import 'package:mocktail/mocktail.dart';

import 'support/localized_pump.dart';

class _MockProcess extends Mock implements ProcessQrScanUseCase {}

class _MockSync extends Mock implements SyncMemberRosterUseCase {}

class _MockRosterRepo extends Mock implements MemberRosterRepository {}

class _TestScannerCubit extends AccessScannerCubit {
  _TestScannerCubit({
    required super.processQrScan,
    required super.syncMemberRoster,
    required super.memberRosterRepository,
    required super.tenantId,
    required super.isOnline,
  });

  void seedSuccess(ScanSuccessNotification success) {
    emit(state.copyWith(success: success));
  }
}

void main() {
  late _TestScannerCubit cubit;
  late _MockProcess process;
  late _MockSync sync;
  late _MockRosterRepo roster;

  setUp(() {
    process = _MockProcess();
    sync = _MockSync();
    roster = _MockRosterRepo();
    when(
      () => roster.countCachedMembers(tenantId: any(named: 'tenantId')),
    ).thenAnswer((_) async => 0);
    cubit = _TestScannerCubit(
      processQrScan: process,
      syncMemberRoster: sync,
      memberRosterRepository: roster,
      tenantId: 't1',
      isOnline: () => false,
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  group('FEAT-16 VF4 G1 citations', () {
    test('cites locked Check-in Gate EN + AR ids', () {
      expect(
        AccessScannerFocusHost.stitchScreenIdEn,
        '3629845f7f1e402697f46cf5575e86da',
      );
      expect(
        AccessScannerFocusHost.stitchScreenIdAr,
        'bec9356e2cb941798e66fa804ac78854',
      );
      expect(
        KineticTokens.stitchAccessScannerScreenId,
        AccessScannerFocusHost.stitchScreenIdEn,
      );
    });

    test('§4.1 fixtures match Stitch sample chrome', () {
      expect(AccessGateStitchFixtures.memberName, 'Marcus Henderson');
      expect(AccessGateStitchFixtures.peakIntensityValue, '94%');
      expect(AccessGateStitchFixtures.avgDwellValue, '68 MIN');
      expect(AccessGateStitchFixtures.guestPassesValue, '04');
      expect(AccessGateStitchFixtures.occupancyCurrent, 42);
      expect(AccessGateStitchFixtures.occupancyLimit, 100);
      expect(AccessGateStitchFixtures.powerScoreValue, '780');
      expect(AccessGateStitchFixtures.systemLog.length, 4);
      expect(AccessGateStitchFixtures.systemId, '098-KM-X');
    });

    test('Install 6-rail preserved; Scan not an index', () {
      expect(PortalShellDestinations.destinationCount, 6);
      expect(PortalShellDestinations.home, 0);
    });
  });

  group('FEAT-16 VF4 G1 regions', () {
    testWidgets('ships full artboard fixtures — never blank shells', (
      tester,
    ) async {
      await pumpLocalizedApp(
        tester,
        BlocProvider<AccessScannerCubit>.value(
          value: cubit,
          child: AccessScannerFocusHost(
            onClose: () {},
            occupancyCurrent: 42,
            occupancyCapacity: 100,
            scanner: const ColoredBox(
              color: KineticTokens.gunmetalCard,
              child: Center(child: Text('scanner-body')),
            ),
          ),
        ),
        waitFor: find.byKey(const Key('check-in-gate-confirm')),
      );

      expect(find.text('KINETIC MONOLITH'), findsWidgets);
      expect(find.textContaining('SECURE ACCESS GATE'), findsOneWidget);
      expect(find.text('Ready - Waiting for Scan'), findsOneWidget);
      expect(find.text('CONFIRM CHECK-IN'), findsOneWidget);
      expect(find.textContaining('098-KM-X'), findsOneWidget);
      expect(find.textContaining('AES-256'), findsOneWidget);
      expect(find.text('94%'), findsOneWidget);
      expect(find.text('68 MIN'), findsOneWidget);
      expect(find.text('04'), findsOneWidget);
      expect(find.byKey(const Key('check-in-gate-occupancy')), findsOneWidget);
      expect(find.text('42'), findsWidgets);
      expect(find.text('Marcus Henderson'), findsOneWidget);
      expect(find.text('Premium Monthly'), findsOneWidget);
      expect(find.text('780'), findsOneWidget);
      expect(find.textContaining('GATE_INIT_SUCCESS'), findsOneWidget);
      expect(find.byKey(const Key('check-in-gate-system-log')), findsOneWidget);
      expect(find.byKey(const Key('check-in-gate-last-member')), findsOneWidget);
      expect(find.byType(CheckInGateLayout), findsOneWidget);
      expect(find.text('scanner-body'), findsOneWidget);
      expect(find.text('—'), findsNothing);
    });

    testWidgets('granted success flips Confirm CTA + last member name', (
      tester,
    ) async {
      await pumpLocalizedApp(
        tester,
        BlocProvider<AccessScannerCubit>.value(
          value: cubit,
          child: AccessScannerFocusHost(
            onClose: () {},
            occupancyCurrent: 42,
            occupancyCapacity: 100,
            scanner: const SizedBox.expand(),
          ),
        ),
        waitFor: find.byKey(const Key('check-in-gate-confirm')),
      );

      cubit.seedSuccess(
        const ScanSuccessNotification(
          memberName: 'Ava Chen',
          occupancy: 43,
          membershipStatus: 'active',
        ),
      );
      await tester.pump();

      expect(find.text('ACCESS GRANTED'), findsOneWidget);
      expect(find.text('Ava Chen'), findsOneWidget);
      expect(find.text('94%'), findsOneWidget);
      expect(find.textContaining('GATE_INIT_SUCCESS'), findsOneWidget);
    });

    testWidgets('close control dismisses focus host', (tester) async {
      var closed = false;
      await pumpLocalizedApp(
        tester,
        BlocProvider<AccessScannerCubit>.value(
          value: cubit,
          child: AccessScannerFocusHost(
            onClose: () => closed = true,
            occupancyCurrent: 3,
            occupancyCapacity: 40,
            scanner: const SizedBox.expand(),
          ),
        ),
        waitFor: find.byKey(const Key('access-scanner-focus-close')),
      );

      await tester.tap(find.byKey(const Key('access-scanner-focus-close')));
      await tester.pump();
      expect(closed, isTrue);
    });
  });
}
