import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fithub_portal_admin/features/access_scanner/presentation/hid_burst_buffer.dart';
import 'package:fithub_portal_admin/features/access_scanner/presentation/widgets/desk_gun_ready_banner.dart';
import 'package:fithub_portal_admin/features/gym_onboarding/presentation/screens/gym_onboarding_wizard_page.dart';
import 'package:fithub_portal_admin/features/gym_onboarding/presentation/widgets/stitch_kinetic_chrome.dart';
import 'package:fithub_portal_admin/features/gym_operations/presentation/scanner_input_cubit.dart';
import 'package:fithub_portal_admin/features/gym_operations/presentation/screens/gym_operations_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/localized_pump.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('FEAT-96/97 formMaxWidth is 720', () {
    expect(GymOnboardingWizardPage.formMaxWidth, 720);
    expect(StitchKineticChrome.formMaxWidth, 720);
  });

  test('FEAT-97 Stitch ids match inventory', () {
    expect(
      GymOperationsScreen.stitchScreenIdEn,
      'aa6f5bb356214f67b22ab8e840f12d96',
    );
    expect(
      GymOperationsScreen.stitchScreenIdAr,
      'a718b3ad19fd4640adf2ceebc77ddf1f',
    );
    expect(
      DeskGunReadyBanner.stitchScreenIdEn,
      '8b38c6168f824bebab709b919f2dc24f',
    );
    expect(
      DeskGunReadyBanner.stitchScreenIdAr,
      '210e882c2bb44d71bac5aa78a1e0a493',
    );
  });

  test('HID burst ignores slow typing and flushes on Enter', () {
    final captured = <String>[];
    final hid = HidBurstBuffer(onBurst: captured.add);

    hid.handle(
      const KeyDownEvent(
        physicalKey: PhysicalKeyboardKey.keyA,
        logicalKey: LogicalKeyboardKey.keyA,
        timeStamp: Duration.zero,
        character: 'a',
      ),
    );
    hid.handle(
      const KeyDownEvent(
        physicalKey: PhysicalKeyboardKey.enter,
        logicalKey: LogicalKeyboardKey.enter,
        timeStamp: Duration.zero,
      ),
    );
    expect(captured, ['a']);
  });

  testWidgets('Operations radios match Stitch hybrid default', (tester) async {
    final cubit = ScannerInputCubit(canWrite: true);
    await cubit.load();
    await pumpLocalizedApp(
      tester,
      BlocProvider.value(
        value: cubit,
        child: const Scaffold(body: GymOperationsScreen()),
      ),
      waitFor: find.byKey(const Key('scanner-mode-hybrid')),
    );

    expect(find.text('OPERATIONS'), findsWidgets);
    expect(find.byKey(const Key('scanner-mode-hardware_gun')), findsOneWidget);
    expect(find.byKey(const Key('scanner-mode-webcam')), findsOneWidget);
    expect(cubit.state.draft, ScannerInputMode.hybrid);

    await tester.tap(find.byKey(const Key('scanner-mode-hardware_gun')));
    await tester.pump();
    expect(cubit.state.draft, ScannerInputMode.hardwareGun);
    await cubit.close();
  });

  testWidgets('Gun banner has Ready for Gun Scan and no camera box', (
    tester,
  ) async {
    await pumpLocalizedApp(
      tester,
      const Scaffold(body: DeskGunReadyBanner()),
      waitFor: find.text('READY FOR GUN SCAN'),
    );
    expect(find.textContaining('Point the gun'), findsOneWidget);
    expect(find.byType(Placeholder), findsNothing);
  });
}
