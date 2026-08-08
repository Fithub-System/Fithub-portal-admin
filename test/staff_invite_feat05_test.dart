import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fithub_portal_admin/core/network/cloud_mutation_guard.dart';
import 'package:fithub_portal_admin/config/theme/kinetic_tokens.dart';
import 'package:fithub_portal_admin/features/auth/domain/entities/employee_profile.dart';
import 'package:fithub_portal_admin/features/staff_invite/domain/entities/staff_invite.dart';
import 'package:fithub_portal_admin/features/staff_invite/domain/entities/staff_role.dart';
import 'package:fithub_portal_admin/features/staff_invite/domain/repositories/staff_invite_repository.dart';
import 'package:fithub_portal_admin/features/staff_invite/domain/staff_invite_failure.dart';
import 'package:fithub_portal_admin/features/staff_invite/domain/use_cases/staff_invite_use_case.dart';
import 'package:fithub_portal_admin/features/staff_invite/presentation/bloc/staff_invite_bloc.dart';
import 'package:fithub_portal_admin/features/staff_invite/presentation/screens/staff_invite_screen.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements StaffInviteRepository {}

void main() {
  late _MockRepo repository;
  late InviteStaffUseCase useCase;

  setUpAll(() {
    registerFallbackValue(
      const StaffInvite(email: 'a@b.c', role: StaffRole.admin, name: 'N'),
    );
  });

  setUp(() {
    repository = _MockRepo();
    useCase = InviteStaffUseCase(repository, cloudGuard: CloudMutationGuard(isOnline: () => true));
  });

  group('FEAT-05 AC-B4 — Admin gate on profile', () {
    test('Admin can invite; Receptionist cannot', () {
      const admin = EmployeeProfile(
        id: '1',
        tenantId: 't1',
        userId: 'u1',
        name: 'A',
        role: 'Admin',
      );
      const receptionist = EmployeeProfile(
        id: '2',
        tenantId: 't1',
        userId: 'u2',
        name: 'R',
        role: 'Receptionist',
      );
      expect(admin.canInviteStaff, isTrue);
      expect(receptionist.canInviteStaff, isFalse);
    });
  });

  group('InviteStaffUseCase validation', () {
    test('rejects empty name/email', () async {
      expect(
        () => useCase(
          const StaffInvite(email: ' ', role: StaffRole.coach, name: 'Ada'),
        ),
        throwsA(isA<StaffInviteValidationFailure>()),
      );
    });

    test('forwards normalized invite to repository', () async {
      when(() => repository.inviteStaff(any())).thenAnswer(
        (_) async => const StaffInviteResult(
          employeeId: 'e1',
          userId: 'u1',
          tenantId: 't1',
          role: StaffRole.coach,
          message: 'ok',
        ),
      );

      final result = await useCase(
        const StaffInvite(
          email: ' Coach@Gym.COM ',
          role: StaffRole.coach,
          name: ' Ada Lovelace ',
        ),
      );

      expect(result.employeeId, 'e1');
      final captured =
          verify(() => repository.inviteStaff(captureAny())).captured.single
              as StaffInvite;
      expect(captured.email, 'coach@gym.com');
      expect(captured.name, 'Ada Lovelace');
      expect(captured.role, StaffRole.coach);
    });
  });

  group('StaffInviteBloc', () {
    test('submits selected role and emits success', () async {
      when(() => repository.inviteStaff(any())).thenAnswer(
        (_) async => const StaffInviteResult(
          employeeId: 'e1',
          userId: 'u1',
          tenantId: 't1',
          role: StaffRole.admin,
          message: 'Staff invited',
        ),
      );

      final bloc = StaffInviteBloc(inviteStaffUseCase: useCase);
      final states = <StaffInviteState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const StaffInviteRoleSelected(StaffRole.admin));
      await Future<void>.delayed(Duration.zero);
      bloc.add(
        const StaffInviteSubmitted(email: 'admin@gym.com', name: 'New Admin'),
      );

      final deadline = DateTime.now().add(const Duration(seconds: 2));
      while (states.whereType<StaffInviteSuccess>().isEmpty &&
          DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      await sub.cancel();

      expect(states.whereType<StaffInviteSubmitting>(), isNotEmpty);
      expect(states.whereType<StaffInviteSuccess>(), isNotEmpty);
      final captured =
          verify(() => repository.inviteStaff(captureAny())).captured.single
              as StaffInvite;
      expect(captured.role, StaffRole.admin);
      await bloc.close();
    });

    test('maps forbidden failure to form message', () async {
      when(
        () => repository.inviteStaff(any()),
      ).thenThrow(const StaffInviteForbiddenFailure());

      final bloc = StaffInviteBloc(inviteStaffUseCase: useCase);
      final states = <StaffInviteState>[];
      final sub = bloc.stream.listen(states.add);
      bloc.add(const StaffInviteSubmitted(email: 'x@y.z', name: 'X'));

      final deadline = DateTime.now().add(const Duration(seconds: 2));
      while (states.length < 2 && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      await sub.cancel();

      final form = states.whereType<StaffInviteFormState>().last;
      expect(form.messageKey, 'staff_invite.error.forbidden');
      await bloc.close();
    });
  });

  group('Stitch citation (Verification Audit)', () {
    test('Staff Management screen id matches KineticTokens', () {
      expect(
        StaffInviteScreen.stitchScreenId,
        KineticTokens.stitchStaffInviteScreenId,
      );
      expect(
        StaffInviteScreen.stitchScreenId,
        'dcc070ef2b1e45058b3e042ad70140e3',
      );
      expect(StaffInviteScreen.stitchScreenTitle, 'Staff Management');
    });
  });

  group('AC-B2 — no public Portal register CTA', () {
    test('login translations and page omit Register CTA', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final enRaw = await rootBundle.loadString('assets/translations/en.json');
      final en = jsonDecode(enRaw) as Map<String, dynamic>;
      final login = en['auth']['login'] as Map<String, dynamic>;
      expect(login.containsKey('register'), isFalse);
      expect(login.containsKey('sign_up'), isFalse);
      expect(
        login.keys.where((k) => '$k'.toLowerCase().contains('register')),
        isEmpty,
      );
    });
  });
}
