import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fithub_portal_admin/features/access_scanner/domain/entities/member_roster_entry.dart';
import 'package:fithub_portal_admin/features/home/presentation/pages/portal_shell_destinations.dart';
import 'package:fithub_portal_admin/features/members/presentation/cubit/member_roster_cubit.dart';
import 'package:fithub_portal_admin/features/members/presentation/screens/member_management_screen.dart';
import 'package:fithub_portal_admin/features/memberships/domain/entities/membership_plan.dart';
import 'package:fithub_portal_admin/features/memberships/presentation/cubit/memberships_cubit.dart';
import 'package:mocktail/mocktail.dart';

import 'support/localized_pump.dart';

class _MockMembershipsCubit extends Mock implements MembershipsCubit {}

class _MockMemberRosterCubit extends Mock implements MemberRosterCubit {}

void main() {
  group('FEAT-07-R shell nav indices', () {
    test('Members is index 1 under FEAT-11 six-destination shell', () {
      // FEAT-11 I1: Home | Members | Staff | Classes | Marketing | Reports
      expect(PortalShellDestinations.home, 0);
      expect(PortalShellDestinations.members, 1);
      expect(PortalShellDestinations.marketing, 4);
      expect(PortalShellDestinations.destinationCount, 6);
    });
  });

  group('Stitch Member Management citation', () {
    test('MemberManagementScreen cites Stitch screen id', () {
      expect(
        MemberManagementScreen.stitchScreenId,
        '9b35dd57f15443e99f7e798f6867acb6',
      );
      expect(
        MemberManagementScreen.stitchScreenTitle,
        'Member Management',
      );
    });
  });

  group('MemberManagementScreen widget smoke', () {
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
        MemberRosterState(
          status: MemberRosterStatus.ready,
          members: [
            MemberRosterEntry(
              id: 'a1',
              fullName: 'Ada',
              powerScore: 100,
              cryptoSalt: 'salt',
              createdAt: DateTime.utc(2026, 1, 1),
              membershipPlanName: 'Monthly',
              membershipStatus: 'active',
            ),
          ],
        ),
      );
      when(() => rosterCubit.stream).thenAnswer(
        (_) => Stream.value(
          MemberRosterState(
            status: MemberRosterStatus.ready,
            members: [
              MemberRosterEntry(
                id: 'a1',
                fullName: 'Ada',
                powerScore: 100,
                cryptoSalt: 'salt',
                createdAt: DateTime.utc(2026, 1, 1),
                membershipPlanName: 'Monthly',
                membershipStatus: 'active',
              ),
            ],
          ),
        ),
      );
      when(() => rosterCubit.load()).thenAnswer((_) async {});
    });

    testWidgets('renders Active Roster with Plan Type column', (tester) async {
      await pumpLocalizedApp(
        tester,
        MultiBlocProvider(
          providers: [
            BlocProvider<MembershipsCubit>.value(value: membershipsCubit),
            BlocProvider<MemberRosterCubit>.value(value: rosterCubit),
          ],
          child: const MemberManagementScreen(canWrite: true),
        ),
        waitFor: find.text('ACTIVE ROSTER'),
      );

      expect(find.text('ACTIVE ROSTER'), findsOneWidget);
      expect(find.text('Plan Type'), findsOneWidget);
      expect(find.text('Ada'), findsOneWidget);
      expect(find.text('STANDARD'), findsOneWidget);
      expect(find.text('FREEZE'), findsOneWidget);
      expect(find.text('RENEW'), findsOneWidget);
      expect(find.byType(TabBar), findsNothing);
    });

    testWidgets('Filter Type opens plans sheet (FEAT-07, no freehand tab)', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await pumpLocalizedApp(
        tester,
        MultiBlocProvider(
          providers: [
            BlocProvider<MembershipsCubit>.value(value: membershipsCubit),
            BlocProvider<MemberRosterCubit>.value(value: rosterCubit),
          ],
          child: const Scaffold(
            body: MemberManagementScreen(canWrite: false),
          ),
        ),
        waitFor: find.text('Filter Type'),
      );

      await tester.tap(find.text('Filter Type'));
      await tester.pumpAndSettle();

      expect(find.text('PLANS'), findsWidgets);
      expect(
        find.text(
          'Receptionist view — only Admins can create or assign memberships.',
        ),
        findsOneWidget,
      );
    });
  });
}
