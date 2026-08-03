import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fithub_portal_admin/features/access_scanner/domain/entities/member_roster_entry.dart';
import 'package:fithub_portal_admin/features/home/presentation/pages/portal_shell_destinations.dart';
import 'package:fithub_portal_admin/features/members/presentation/cubit/member_roster_cubit.dart';
import 'package:fithub_portal_admin/features/members/presentation/fixtures/members_stitch_fixtures.dart';
import 'package:fithub_portal_admin/features/members/presentation/screens/member_management_screen.dart';
import 'package:fithub_portal_admin/features/members/presentation/widgets/member_roster_table.dart';
import 'package:fithub_portal_admin/features/members/presentation/widgets/members_roster_chrome.dart';
import 'package:fithub_portal_admin/features/members/presentation/widgets/members_stats_bento.dart';
import 'package:fithub_portal_admin/features/memberships/presentation/cubit/memberships_cubit.dart';
import 'package:mocktail/mocktail.dart';

import 'support/localized_pump.dart';

class _MockMembershipsCubit extends Mock implements MembershipsCubit {}

class _MockMemberRosterCubit extends Mock implements MemberRosterCubit {}

void main() {
  group('FEAT-16 VF2 Members citations', () {
    test('cites locked Member Management screen + AR twin', () {
      expect(
        MemberManagementScreen.stitchScreenId,
        '9b35dd57f15443e99f7e798f6867acb6',
      );
      expect(
        MemberManagementScreen.stitchScreenIdAr,
        '60b6a0e1f7fb4419b1b0e774ec8bdb32',
      );
      expect(MembersStitchFixtures.sampleRows.length, 4);
      expect(MembersStitchFixtures.sampleRows.first.fullName, 'Dominic Russo');
    });

    test('Install 6-rail Members index unchanged', () {
      expect(PortalShellDestinations.destinationCount, 6);
      expect(PortalShellDestinations.members, 1);
    });
  });

  group('FEAT-16 VF2 Members regions + §4.1 fixtures', () {
    late _MockMembershipsCubit membershipsCubit;
    late _MockMemberRosterCubit rosterCubit;

    setUp(() {
      membershipsCubit = _MockMembershipsCubit();
      rosterCubit = _MockMemberRosterCubit();

      when(() => membershipsCubit.state).thenReturn(
        const MembershipsState(status: MembershipsStatus.ready, plans: []),
      );
      when(() => membershipsCubit.stream).thenAnswer(
        (_) => Stream.value(
          const MembershipsState(status: MembershipsStatus.ready, plans: []),
        ),
      );
      when(() => membershipsCubit.load()).thenAnswer((_) async {});

      when(() => rosterCubit.state).thenReturn(
        const MemberRosterState(status: MemberRosterStatus.ready),
      );
      when(() => rosterCubit.stream).thenAnswer(
        (_) => Stream.value(
          const MemberRosterState(status: MemberRosterStatus.ready),
        ),
      );
      when(() => rosterCubit.load()).thenAnswer((_) async {});
    });

    testWidgets('empty cache ships Stitch fixture rows and chrome', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1400, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await pumpLocalizedApp(
        tester,
        MultiBlocProvider(
          providers: [
            BlocProvider<MembershipsCubit>.value(value: membershipsCubit),
            BlocProvider<MemberRosterCubit>.value(value: rosterCubit),
          ],
          child: const MemberManagementScreen(
            canWrite: true,
            canEnroll: true,
          ),
        ),
        waitFor: find.text('ACTIVE ROSTER'),
      );

      expect(find.byType(TabBar), findsNothing);
      expect(find.byType(MembersStatsBento), findsOneWidget);
      expect(find.byType(MemberRosterTable), findsOneWidget);
      expect(find.byType(MembersRosterPagination), findsOneWidget);
      expect(find.byType(MembersSyncFooter), findsOneWidget);

      expect(find.text('ACTIVE ROSTER'), findsOneWidget);
      expect(find.text('ELITE TIER'), findsOneWidget);
      expect(find.text('124'), findsOneWidget);
      expect(find.text('68.2'), findsOneWidget);
      expect(find.text('42'), findsWidgets);
      expect(find.text('Optimal'), findsOneWidget);

      expect(find.text('Dominic Russo'), findsOneWidget);
      expect(find.text('Sarah Miller'), findsOneWidget);
      expect(find.text('Jason Kang'), findsOneWidget);
      expect(find.text('Elena Belova'), findsOneWidget);
      expect(find.text('ELITE'), findsWidgets);
      expect(find.text('STANDARD'), findsOneWidget);
      expect(find.text('BASIC'), findsOneWidget);
      expect(find.text('FREEZE'), findsWidgets);
      expect(find.text('RENEW'), findsWidgets);
      expect(find.text('FULL EVALUATION'), findsWidgets);
      expect(find.text('Filter Type'), findsOneWidget);
      expect(find.text('Add New Member'), findsOneWidget);
      expect(find.textContaining('1,240'), findsOneWidget);
      expect(find.text('SYNC ACTIVE'), findsOneWidget);
      expect(find.text('API V2.4'), findsOneWidget);

      // Forbidden empty shells
      expect(find.text('—'), findsNothing);
    });

    testWidgets('live roster replaces fixture names with same chrome', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final liveState = MemberRosterState(
        status: MemberRosterStatus.ready,
        members: [
          MemberRosterEntry(
            id: 'live-1',
            fullName: 'Ada Lovelace',
            powerScore: 75,
            cryptoSalt: 'salt',
            createdAt: DateTime.utc(2026, 1, 1),
            membershipPlanName: 'Elite Monthly',
            membershipStatus: 'active',
          ),
        ],
      );
      when(() => rosterCubit.state).thenReturn(liveState);
      when(() => rosterCubit.stream).thenAnswer((_) => Stream.value(liveState));

      await pumpLocalizedApp(
        tester,
        MultiBlocProvider(
          providers: [
            BlocProvider<MembershipsCubit>.value(value: membershipsCubit),
            BlocProvider<MemberRosterCubit>.value(value: rosterCubit),
          ],
          child: const MemberManagementScreen(canWrite: true, canEnroll: true),
        ),
        waitFor: find.text('Ada Lovelace'),
      );

      expect(find.text('Ada Lovelace'), findsOneWidget);
      expect(find.text('Dominic Russo'), findsNothing);
      expect(find.text('ELITE'), findsOneWidget);
      expect(find.text('75'), findsOneWidget);
      expect(find.byType(MembersStatsBento), findsOneWidget);
    });

    testWidgets('receptionist sees Add New Member chrome disabled', (
      tester,
    ) async {
      await pumpLocalizedApp(
        tester,
        MultiBlocProvider(
          providers: [
            BlocProvider<MembershipsCubit>.value(value: membershipsCubit),
            BlocProvider<MemberRosterCubit>.value(value: rosterCubit),
          ],
          child: const MemberManagementScreen(
            canWrite: false,
            canEnroll: false,
          ),
        ),
        waitFor: find.text('Add New Member'),
      );

      expect(find.text('Add New Member'), findsOneWidget);
      final button = tester.widget<FilledButton>(find.widgetWithText(
        FilledButton,
        'Add New Member',
      ));
      expect(button.onPressed, isNull);
    });
  });
}
