import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fithub_portal_admin/core/i18n/app_locales.dart';
import 'package:fithub_portal_admin/core/network/cloud_mutation_guard.dart';
import 'package:fithub_portal_admin/features/add_member/domain/entities/athlete_enroll_match.dart';
import 'package:fithub_portal_admin/features/add_member/domain/entities/member_invite.dart';
import 'package:fithub_portal_admin/features/add_member/domain/repositories/add_member_repository.dart';
import 'package:fithub_portal_admin/features/add_member/domain/use_cases/add_member_use_cases.dart';
import 'package:fithub_portal_admin/features/add_member/presentation/bloc/add_member_bloc.dart';
import 'package:fithub_portal_admin/features/add_member/presentation/screens/add_member_screen.dart';
import 'package:fithub_portal_admin/features/memberships/domain/repositories/memberships_repository.dart';
import 'package:fithub_portal_admin/features/memberships/domain/use_cases/memberships_use_cases.dart';
import 'package:mocktail/mocktail.dart';

import 'support/localized_pump.dart';

class _MockAddMemberRepo extends Mock implements AddMemberRepository {}

class _MockMembershipsRepo extends Mock implements MembershipsRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(const MemberInvite(email: 'fallback@example.com'));
  });

  AddMemberBloc buildBloc(_MockAddMemberRepo addRepo) {
    final membershipsRepo = _MockMembershipsRepo();
    when(
      () => membershipsRepo.listPlans(activeOnly: any(named: 'activeOnly')),
    ).thenAnswer((_) async => const []);
    when(
      () => addRepo.searchAthletesForDesk(any()),
    ).thenAnswer((_) async => const []);
    when(
      () => addRepo.findAthleteForEnroll(any()),
    ).thenAnswer((_) async => null);
    return AddMemberBloc(
      findAthlete: FindAthleteForEnrollUseCase(addRepo),
      searchAthletes: SearchAthletesForDeskUseCase(addRepo),
      enrollGymMember: EnrollGymMemberUseCase(addRepo),
      inviteMember: InviteMemberUseCase(
        addRepo,
        cloudGuard: CloudMutationGuard(isOnline: () => true),
      ),
      listPlans: ListMembershipPlansUseCase(membershipsRepo),
      assignMembership: AssignMembershipUseCase(membershipsRepo),
    );
  }

  test('cites locked G4 ids, dialog radius, debounce', () {
    expect(
      AddMemberScreen.stitchScreenIdEn,
      'cd59a129a24449478a5249ccb41635fb',
    );
    expect(
      AddMemberScreen.stitchScreenIdAr,
      '89fe5d7afb8d4d4384d7e6498bcdd065',
    );
    expect(AddMemberScreen.formMaxWidth, 720);
    expect(AddMemberScreen.dialogRadius, 16);
    expect(AddMemberScreen.searchDebounce.inMilliseconds, 300);
  });

  test('desk search maps cards without requiring @', () async {
    final addRepo = _MockAddMemberRepo();
    final bloc = buildBloc(addRepo);
    when(() => addRepo.searchAthletesForDesk('917')).thenAnswer(
      (_) async => const [
        AthleteEnrollMatch(
          id: 'a1',
          fullName: 'Ada',
          publicCode: 'FH-0001',
          phoneE164: '+201000000000',
        ),
      ],
    );
    addTearDown(bloc.close);
    bloc.add(const AddMemberSearchRequested('917'));
    await pumpEventQueue();
    expect(bloc.state.status, AddMemberStatus.found);
    expect(bloc.state.match?.id, 'a1');
    expect(bloc.state.matches, hasLength(1));
  });

  testWidgets('AR dialog is overlay+stepper, not tabs; search is LTR', (
    tester,
  ) async {
    final addRepo = _MockAddMemberRepo();
    final pending = Completer<List<AthleteEnrollMatch>>();
    when(
      () => addRepo.searchAthletesForDesk(any()),
    ).thenAnswer((_) => pending.future);
    when(
      () => addRepo.findAthleteForEnroll(any()),
    ).thenAnswer((_) async => null);
    final membershipsRepo = _MockMembershipsRepo();
    when(
      () => membershipsRepo.listPlans(activeOnly: any(named: 'activeOnly')),
    ).thenAnswer((_) async => const []);
    final bloc = AddMemberBloc(
      findAthlete: FindAthleteForEnrollUseCase(addRepo),
      searchAthletes: SearchAthletesForDeskUseCase(addRepo),
      enrollGymMember: EnrollGymMemberUseCase(addRepo),
      inviteMember: InviteMemberUseCase(
        addRepo,
        cloudGuard: CloudMutationGuard(isOnline: () => true),
      ),
      listPlans: ListMembershipPlansUseCase(membershipsRepo),
      assignMembership: AssignMembershipUseCase(membershipsRepo),
    );
    addTearDown(bloc.close);

    await pumpLocalizedApp(
      tester,
      BlocProvider.value(value: bloc, child: const AddMemberScreen()),
      locale: AppLocales.ar,
    );
    await tester.pumpAndSettle();

    expect(find.byType(TabBar), findsNothing);
    expect(find.byType(BackdropFilter), findsOneWidget);
    expect(find.text('إضافة عضو جديد'), findsOneWidget);
    expect(find.text('البحث أو الدعوة'), findsOneWidget);
    expect(find.text('تعيين الخطة'), findsOneWidget);
    expect(find.text('إلغاء الطلب'), findsOneWidget);
    expect(find.text('التالي: الخطوة 2'), findsOneWidget);
    expect(find.text('تسجيل وتعيين الرياضي'), findsOneWidget);

    final search = tester.widget<TextField>(
      find.byKey(const Key('add_member_search_field')),
    );
    expect(search.decoration?.prefixIcon, isA<Icon>());
    expect(search.decoration?.suffix, isNull);

    await tester.enterText(
      find.byKey(const Key('add_member_search_field')),
      '55-0198',
    );
    await tester.pump(AddMemberScreen.searchDebounce);
    await tester.pump();
    expect(find.text('جاري البحث'), findsOneWidget);
    final searchingField = tester.widget<TextField>(
      find.byKey(const Key('add_member_search_field')),
    );
    expect(searchingField.decoration?.suffix, isA<Text>());
    expect(searchingField.decoration?.prefixIcon, isA<Icon>());
    pending.complete(const []);
    await tester.pumpAndSettle();
  });
}
