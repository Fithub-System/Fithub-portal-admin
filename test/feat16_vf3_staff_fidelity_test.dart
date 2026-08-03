import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fithub_portal_admin/config/theme/kinetic_tokens.dart';
import 'package:fithub_portal_admin/features/home/presentation/pages/portal_shell_destinations.dart';
import 'package:fithub_portal_admin/features/staff_invite/domain/entities/staff_invite.dart';
import 'package:fithub_portal_admin/features/staff_invite/domain/entities/staff_role.dart';
import 'package:fithub_portal_admin/features/staff_invite/domain/repositories/staff_invite_repository.dart';
import 'package:fithub_portal_admin/features/staff_invite/domain/use_cases/staff_invite_use_case.dart';
import 'package:fithub_portal_admin/features/staff_invite/presentation/bloc/staff_invite_bloc.dart';
import 'package:fithub_portal_admin/features/staff_invite/presentation/fixtures/staff_stitch_fixtures.dart';
import 'package:fithub_portal_admin/features/staff_invite/presentation/screens/staff_invite_screen.dart';
import 'package:fithub_portal_admin/features/staff_invite/presentation/screens/staff_management_screen.dart';
import 'package:fithub_portal_admin/features/staff_invite/presentation/widgets/staff_audit_security.dart';
import 'package:fithub_portal_admin/features/staff_invite/presentation/widgets/staff_profile_header.dart';
import 'package:fithub_portal_admin/features/staff_invite/presentation/widgets/staff_shift_log_table.dart';
import 'package:mocktail/mocktail.dart';

import 'support/localized_pump.dart';

class _MockRepo extends Mock implements StaffInviteRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const StaffInvite(email: 'a@b.c', role: StaffRole.coach, name: 'N'),
    );
  });

  group('FEAT-16 VF3 Staff citations', () {
    test('cites locked Staff Management screen + AR twin', () {
      expect(
        StaffManagementScreen.stitchScreenId,
        'dcc070ef2b1e45058b3e042ad70140e3',
      );
      expect(
        StaffManagementScreen.stitchScreenIdAr,
        '6388be3944bb49aa854b41cfaab32135',
      );
      expect(
        StaffManagementScreen.stitchScreenId,
        KineticTokens.stitchStaffInviteScreenId,
      );
      expect(StaffInviteScreen.stitchScreenId, StaffManagementScreen.stitchScreenId);
      expect(StaffStitchFixtures.shiftRows.length, 4);
      expect(StaffStitchFixtures.shiftRows.first.fullName, 'Elena Rodriguez');
      expect(StaffStitchFixtures.activeShiftsValue, '14');
    });

    test('Install 6-rail Staff index unchanged', () {
      expect(PortalShellDestinations.destinationCount, 6);
      expect(PortalShellDestinations.staff, 2);
    });
  });

  group('FEAT-16 VF3 Staff regions + §4.1 fixtures', () {
    late _MockRepo repo;
    late StaffInviteBloc bloc;

    setUp(() {
      repo = _MockRepo();
      when(() => repo.inviteStaff(any())).thenAnswer(
        (_) async => const StaffInviteResult(
          employeeId: 'e1',
          userId: 'u1',
          tenantId: 't1',
          role: StaffRole.coach,
          message: 'ok',
        ),
      );
      bloc = StaffInviteBloc(inviteStaffUseCase: InviteStaffUseCase(repo));
    });

    tearDown(() async {
      await bloc.close();
    });

    testWidgets('ships full artboard fixtures — never blank shells', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1400, 1800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await pumpLocalizedApp(
        tester,
        BlocProvider.value(
          value: bloc,
          child: const StaffManagementScreen(canInvite: true),
        ),
        waitFor: find.text('STAFF PROFILE CREATOR'),
      );

      expect(find.byType(StaffProfileHeader), findsOneWidget);
      expect(find.byType(StaffShiftLogTable), findsOneWidget);
      expect(find.byType(StaffAuditFeed), findsOneWidget);
      expect(find.byType(StaffSecurityComplianceTile), findsOneWidget);

      expect(find.text('STAFF PROFILE CREATOR'), findsOneWidget);
      expect(find.text('14'), findsOneWidget);
      expect(find.text('ACTIVE SHIFTS'), findsOneWidget);
      expect(find.text('IDENTITY & CREDENTIALS'), findsOneWidget);
      expect(find.text('ACCESS PROTOCOL'), findsOneWidget);
      expect(find.text('INITIALIZE PROFILE'), findsOneWidget);
      expect(find.text('Trainer'), findsWidgets);
      expect(find.text('Front Desk'), findsWidgets);
      expect(find.text('Admin'), findsWidgets);

      expect(find.text('Elena Rodriguez'), findsOneWidget);
      expect(find.text('Marcus Thorne'), findsOneWidget);
      expect(find.text('Sarah Jenkins'), findsOneWidget);
      expect(find.text('Alex Chen'), findsOneWidget);
      expect(find.text('8.35h'), findsOneWidget);
      expect(find.text('6.00h'), findsOneWidget);
      expect(find.text('--:--'), findsWidgets);
      expect(find.textContaining('Updated Permissions'), findsOneWidget);
      expect(find.textContaining('New Profile Created'), findsOneWidget);
      expect(find.textContaining('SECURITY'), findsOneWidget);
      expect(find.text('SYSTEM SECURE'), findsOneWidget);
      expect(find.text('EXPORT CSV'), findsOneWidget);
      expect(find.text('FILTER RANGE'), findsOneWidget);
      expect(find.text('Hypertrophy Specialist'), findsOneWidget);

      // No bare placeholder dashes as lone cells beyond Stitch clock-out chrome.
      expect(find.text('—'), findsNothing);
      expect(find.textContaining('Coming soon'), findsNothing);
    });

    testWidgets('!canInvite keeps chrome; CTA disabled + forbidden', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1400, 1800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await pumpLocalizedApp(
        tester,
        BlocProvider.value(
          value: bloc,
          child: const StaffManagementScreen(canInvite: false),
        ),
        waitFor: find.text('STAFF PROFILE CREATOR'),
      );

      expect(find.text('Elena Rodriguez'), findsOneWidget);
      expect(find.text('SYSTEM SECURE'), findsOneWidget);
      expect(find.text('Only Admins can invite staff.'), findsOneWidget);

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('Initialize Profile submits FEAT-05 invite', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 1800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await pumpLocalizedApp(
        tester,
        BlocProvider.value(
          value: bloc,
          child: const StaffManagementScreen(canInvite: true),
        ),
        waitFor: find.text('STAFF PROFILE CREATOR'),
      );

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Ada Lovelace',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'ada@kinetic.com',
      );
      await tester.tap(find.text('INITIALIZE PROFILE'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      verify(
        () => repo.inviteStaff(
          any(
            that: isA<StaffInvite>()
                .having((i) => i.email, 'email', 'ada@kinetic.com')
                .having((i) => i.name, 'name', 'Ada Lovelace')
                .having((i) => i.role, 'role', StaffRole.coach),
          ),
        ),
      ).called(1);
    });
  });
}
