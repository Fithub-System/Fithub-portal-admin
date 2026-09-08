import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fithub_portal_admin/config/theme/kinetic_tokens.dart';
import 'package:fithub_portal_admin/features/access_scanner/domain/repositories/member_roster_repository.dart';
import 'package:fithub_portal_admin/features/access_scanner/domain/use_cases/process_qr_scan_use_case.dart';
import 'package:fithub_portal_admin/features/access_scanner/domain/use_cases/sync_member_roster_use_case.dart';
import 'package:fithub_portal_admin/features/access_scanner/presentation/cubit/access_scanner_cubit.dart';
import 'package:fithub_portal_admin/features/access_scanner/presentation/cubit/access_scanner_state.dart';
import 'package:fithub_portal_admin/features/access_scanner/presentation/screens/access_scanner_screen.dart';
import 'package:fithub_portal_admin/features/access_scanner/presentation/widgets/check_in_gate_layout.dart';
import 'package:fithub_portal_admin/features/home/presentation/widgets/access_scanner_focus_host.dart';

import 'support/localized_pump.dart';

class _MockProcess extends Mock implements ProcessQrScanUseCase {}

class _MockSync extends Mock implements SyncMemberRosterUseCase {}

class _MockRosterRepo extends Mock implements MemberRosterRepository {}

/// Harness that surfaces [AccessScannerState.showManualEntryCta] without
/// `mobile_scanner` platform channels.
class _ManualCtaHarness extends StatelessWidget {
  const _ManualCtaHarness();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccessScannerCubit, AccessScannerState>(
      builder: (context, state) {
        if (!state.showManualEntryCta) {
          return const SizedBox.shrink(
            key: Key('access-scanner-manual-hidden'),
          );
        }
        return FloatingActionButton.extended(
          key: const Key('access-scanner-manual-entry-cta'),
          onPressed: () {},
          label: Text('Enter code'),
        );
      },
    );
  }
}

void main() {
  late AccessScannerCubit cubit;
  late _MockProcess process;
  late _MockSync sync;
  late _MockRosterRepo roster;

  AccessScannerCubit buildCubit() {
    return AccessScannerCubit(
      processQrScan: process,
      syncMemberRoster: sync,
      memberRosterRepository: roster,
      tenantId: 'tenant-1',
      isOnline: () => false,
    );
  }

  setUp(() {
    process = _MockProcess();
    sync = _MockSync();
    roster = _MockRosterRepo();
    when(
      () => roster.countCachedMembers(tenantId: any(named: 'tenantId')),
    ).thenAnswer((_) async => 0);
    cubit = buildCubit();
  });

  tearDown(() async {
    await cubit.close();
  });

  group('FEAT-58 Stitch citations', () {
    test('cites G1 Check-in Gate EN+AR', () {
      expect(
        AccessScannerScreen.stitchScreenId,
        '3629845f7f1e402697f46cf5575e86da',
      );
      expect(
        AccessScannerScreen.stitchScreenIdAr,
        'bec9356e2cb941798e66fa804ac78854',
      );
      expect(
        AccessScannerFocusHost.stitchScreenIdEn,
        AccessScannerScreen.stitchScreenId,
      );
      expect(
        KineticTokens.stitchAccessScannerScreenId,
        AccessScannerScreen.stitchScreenId,
      );
    });
  });

  group('FEAT-58 camera ready state (AC-A1)', () {
    test('markCameraReady clears pending without requiring a barcode', () {
      expect(cubit.state.cameraReady, isFalse);
      expect(cubit.state.showManualEntryCta, isTrue);

      cubit.markCameraReady();

      expect(cubit.state.cameraReady, isTrue);
      expect(cubit.state.cameraError, isFalse);
      expect(cubit.state.showManualEntryCta, isFalse);
    });

    test('markCameraReady is idempotent', () async {
      final states = <AccessScannerState>[];
      final sub = cubit.stream.listen(states.add);
      cubit.markCameraReady();
      cubit.markCameraReady();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await sub.cancel();

      expect(states, hasLength(1));
      expect(states.single.cameraReady, isTrue);
    });

    test('markCameraError exposes production manual CTA', () {
      cubit.markCameraError();

      expect(cubit.state.cameraError, isTrue);
      expect(cubit.state.cameraReady, isFalse);
      expect(cubit.state.showManualEntryCta, isTrue);
    });

    test('markCameraReady after error recovers ready chrome', () {
      cubit.markCameraError();
      cubit.markCameraReady();

      expect(cubit.state.cameraReady, isTrue);
      expect(cubit.state.cameraError, isFalse);
      expect(cubit.state.showManualEntryCta, isFalse);
    });
  });

  group('FEAT-58 gate overlay (AC-A1 / AC-A3)', () {
    testWidgets('pending overlay shows actionable copy before stream ready', (
      tester,
    ) async {
      await pumpLocalizedApp(
        tester,
        BlocProvider<AccessScannerCubit>.value(
          value: cubit,
          child: AccessScannerFocusHost(
            onClose: () {},
            occupancyCurrent: 1,
            occupancyCapacity: 40,
            scanner: const ColoredBox(
              color: KineticTokens.gunmetalCard,
              child: Center(child: Text('scanner-body')),
            ),
          ),
        ),
        waitFor: find.byKey(const Key('access-scanner-pending-overlay')),
      );

      expect(
        find.byKey(const Key('access-scanner-pending-overlay')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('access-scanner-ready-label')), findsNothing);
      expect(find.textContaining('Allow camera access'), findsOneWidget);
      expect(find.textContaining('Enter code'), findsWidgets);
      expect(find.textContaining('browser may remember'), findsOneWidget);
    });

    testWidgets('ready clears pending overlay without a successful QR', (
      tester,
    ) async {
      await pumpLocalizedApp(
        tester,
        BlocProvider<AccessScannerCubit>.value(
          value: cubit,
          child: AccessScannerFocusHost(
            onClose: () {},
            occupancyCurrent: 1,
            occupancyCapacity: 40,
            scanner: const ColoredBox(
              color: KineticTokens.gunmetalCard,
              child: Center(child: Text('scanner-body')),
            ),
          ),
        ),
        waitFor: find.byKey(const Key('access-scanner-pending-overlay')),
      );

      cubit.markCameraReady();
      await tester.pump();

      expect(
        find.byKey(const Key('access-scanner-pending-overlay')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('access-scanner-ready-label')),
        findsOneWidget,
      );
      expect(find.text('Ready - Waiting for Scan'), findsOneWidget);
      expect(find.byType(CheckInGateLayout), findsOneWidget);
    });

    testWidgets('camera error overlay keeps Enter code path visible', (
      tester,
    ) async {
      cubit.markCameraError();

      await pumpLocalizedApp(
        tester,
        BlocProvider<AccessScannerCubit>.value(
          value: cubit,
          child: AccessScannerFocusHost(
            onClose: () {},
            occupancyCurrent: 1,
            occupancyCapacity: 40,
            scanner: const _ManualCtaHarness(),
          ),
        ),
        waitFor: find.byKey(const Key('access-scanner-pending-overlay')),
      );

      expect(
        find.byKey(const Key('access-scanner-pending-overlay')),
        findsOneWidget,
      );
      expect(find.textContaining('Camera unavailable'), findsOneWidget);
      expect(
        find.byKey(const Key('access-scanner-manual-entry-cta')),
        findsOneWidget,
      );
    });
  });

  group('FEAT-58 AR / RTL (AC-A4)', () {
    testWidgets('AR focus host cites twin Stitch id + permission note', (
      tester,
    ) async {
      cubit.markCameraReady();
      await pumpLocalizedApp(
        tester,
        BlocProvider<AccessScannerCubit>.value(
          value: cubit,
          child: AccessScannerFocusHost(
            onClose: () {},
            occupancyCurrent: 2,
            occupancyCapacity: 40,
            scanner: const SizedBox.expand(),
          ),
        ),
        locale: const Locale('ar'),
        waitFor: find.byKey(const Key('access-scanner-focus-close')),
      );

      expect(
        find.textContaining('bec9356e2cb941798e66fa804ac78854'),
        findsOneWidget,
      );
      expect(find.textContaining('إذن الكاميرا'), findsOneWidget);
      expect(find.text('Ready - Waiting for Scan'), findsOneWidget);
    });
  });
}
