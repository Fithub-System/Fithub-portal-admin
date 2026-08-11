import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fithub_portal_admin/config/theme/kinetic_tokens.dart';
import 'package:fithub_portal_admin/core/i18n/app_locales.dart';
import 'package:fithub_portal_admin/core/network/cloud_mutation_guard.dart';
import 'package:fithub_portal_admin/features/admin_payout_queue/domain/admin_payout_failure.dart';
import 'package:fithub_portal_admin/features/admin_payout_queue/domain/entities/coach_payout_request.dart';
import 'package:fithub_portal_admin/features/admin_payout_queue/domain/repositories/admin_payout_queue_repository.dart';
import 'package:fithub_portal_admin/features/admin_payout_queue/domain/use_cases/admin_payout_queue_use_cases.dart';
import 'package:fithub_portal_admin/features/admin_payout_queue/presentation/bloc/admin_payout_queue_bloc.dart';
import 'package:fithub_portal_admin/features/admin_payout_queue/presentation/screens/admin_payout_queue_screen.dart';
import 'package:fithub_portal_admin/features/admin_payout_queue/presentation/widgets/payout_filter_chips.dart';
import 'package:fithub_portal_admin/features/admin_payout_queue/presentation/widgets/payout_kpi_strip.dart';
import 'package:fithub_portal_admin/features/admin_payout_queue/presentation/widgets/payout_queue_table.dart';
import 'package:fithub_portal_admin/features/auth/domain/entities/employee_profile.dart';
import 'package:fithub_portal_admin/features/home/presentation/pages/portal_shell_destinations.dart';

import 'support/localized_pump.dart';

class _FakePayoutRepo implements AdminPayoutQueueRepository {
  List<CoachPayoutRequest> rows = const [];
  Object? fulfillError;
  int fulfillCalls = 0;

  @override
  Future<List<CoachPayoutRequest>> listRequests({int limit = 100}) async {
    return rows.take(limit).toList(growable: false);
  }

  @override
  Future<CoachPayoutRequest> fulfill({
    required String requestId,
    required AdminPayoutFulfillAction action,
  }) async {
    fulfillCalls += 1;
    final err = fulfillError;
    if (err != null) {
      if (err is Exception) throw err;
      throw Exception('$err');
    }
    final idx = rows.indexWhere((r) => r.id == requestId);
    if (idx < 0) throw const AdminPayoutNotFoundFailure();
    final current = rows[idx];
    final updated = CoachPayoutRequest(
      id: current.id,
      tenantId: current.tenantId,
      coachEmployeeId: current.coachEmployeeId,
      coachDisplayName: current.coachDisplayName,
      amountCents: current.amountCents,
      currency: current.currency,
      status: action == AdminPayoutFulfillAction.paid
          ? CoachPayoutRequestStatus.paid
          : CoachPayoutRequestStatus.rejected,
      createdAt: current.createdAt,
      updatedAt: DateTime.now().toUtc(),
    );
    rows = [
      for (var i = 0; i < rows.length; i++)
        if (i == idx) updated else rows[i],
    ];
    return updated;
  }
}

void main() {
  late _FakePayoutRepo repo;

  setUp(() {
    repo = _FakePayoutRepo();
  });

  AdminPayoutQueueBloc buildBloc({bool online = true}) {
    return AdminPayoutQueueBloc(
      listRequests: ListAdminPayoutRequestsUseCase(repo),
      fulfill: FulfillAdminPayoutUseCase(
        repo,
        cloudGuard: CloudMutationGuard(isOnline: () => online),
      ),
    );
  }

  CoachPayoutRequest pending({
    String id = 'r1',
    String name = 'Maya Okonkwo',
  }) {
    return CoachPayoutRequest(
      id: id,
      tenantId: 't1',
      coachEmployeeId: 'c1',
      coachDisplayName: name,
      amountCents: 125000,
      currency: 'EGP',
      status: CoachPayoutRequestStatus.pending,
      createdAt: DateTime.utc(2026, 8, 9, 14, 22),
    );
  }

  group('FEAT-30 Admin gate', () {
    test('Admin can fulfill; Receptionist read-only', () {
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
      expect(admin.canFulfillPayouts, isTrue);
      expect(receptionist.canFulfillPayouts, isFalse);
      expect(admin.isPortalRole, isTrue);
      expect(receptionist.isPortalRole, isTrue);
    });
  });

  group('FEAT-30 shell IA', () {
    test('Payouts is rail destination before Reports', () {
      expect(PortalShellDestinations.payouts, 5);
      expect(PortalShellDestinations.reports, 6);
      expect(PortalShellDestinations.destinationCount, 7);
    });

    test('cites Stitch EN + AR screen ids + Brand Lock peak', () {
      expect(
        AdminPayoutQueueScreen.stitchScreenIdEn,
        KineticTokens.stitchAdminPayoutQueueScreenIdEn,
      );
      expect(
        AdminPayoutQueueScreen.stitchScreenIdAr,
        KineticTokens.stitchAdminPayoutQueueScreenIdAr,
      );
      expect(
        AdminPayoutQueueScreen.brandLockDsAsset,
        'assets/12737976743993098844',
      );
      expect(KineticTokens.peakCoral, const Color(0xFFFF3B30));
      expect(KineticTokens.electricLime, const Color(0xFFCCFF00));
      expect(KineticTokens.deepCharcoal, const Color(0xFF121212));
    });
  });

  group('AdminPayoutQueueBloc', () {
    test('load emits ready with pending filter default', () async {
      repo.rows = [
        pending(),
        pending(id: 'r2', name: 'Karim').copyWithStatus(
          CoachPayoutRequestStatus.paid,
        ),
      ];

      final bloc = buildBloc();
      bloc.add(const AdminPayoutQueueLoadRequested());
      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<AdminPayoutQueueState>(
            (s) =>
                s.status == AdminPayoutQueueStatus.ready &&
                s.requests.length == 2 &&
                s.filter == AdminPayoutFilter.pending &&
                s.filteredRequests.length == 1 &&
                s.pendingCount == 1,
          ),
        ),
      );
      await bloc.close();
    });

    test('mark paid maps forbidden failure', () async {
      repo.rows = [pending()];
      repo.fulfillError = const AdminPayoutForbiddenFailure();

      final bloc = buildBloc();
      final ready = bloc.stream.firstWhere(
        (s) => s.status == AdminPayoutQueueStatus.ready,
      );
      bloc.add(const AdminPayoutQueueLoadRequested());
      await ready;

      bloc.add(
        const AdminPayoutQueueFulfillRequested(
          requestId: 'r1',
          action: AdminPayoutFulfillAction.paid,
          canWrite: true,
        ),
      );
      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<AdminPayoutQueueState>(
            (s) => s.messageKey == 'payouts.error.forbidden',
          ),
        ),
      );
      await bloc.close();
    });

    test('receptionist canWrite=false emits forbidden without RPC', () async {
      repo.rows = [pending()];

      final bloc = buildBloc();
      final ready = bloc.stream.firstWhere(
        (s) => s.status == AdminPayoutQueueStatus.ready,
      );
      bloc.add(const AdminPayoutQueueLoadRequested());
      await ready;

      bloc.add(
        const AdminPayoutQueueFulfillRequested(
          requestId: 'r1',
          action: AdminPayoutFulfillAction.paid,
          canWrite: false,
        ),
      );
      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<AdminPayoutQueueState>(
            (s) => s.messageKey == 'payouts.error.forbidden',
          ),
        ),
      );
      expect(repo.fulfillCalls, 0);
      await bloc.close();
    });

    test('offline fulfill throws offline key via use case', () async {
      repo.rows = [pending()];

      final bloc = buildBloc(online: false);
      final ready = bloc.stream.firstWhere(
        (s) => s.status == AdminPayoutQueueStatus.ready,
      );
      bloc.add(const AdminPayoutQueueLoadRequested());
      await ready;

      bloc.add(
        const AdminPayoutQueueFulfillRequested(
          requestId: 'r1',
          action: AdminPayoutFulfillAction.rejected,
          canWrite: true,
        ),
      );
      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<AdminPayoutQueueState>(
            (s) => s.messageKey == 'payouts.error.offline',
          ),
        ),
      );
      expect(repo.fulfillCalls, 0);
      await bloc.close();
    });
  });

  group('AdminPayoutQueueScreen UI', () {
    testWidgets('renders header, KPIs, filters, Mark paid for Admin',
        (tester) async {
      repo.rows = [pending()];

      await pumpLocalizedApp(
        tester,
        BlocProvider(
          create: (_) => buildBloc(),
          child: const AdminPayoutQueueScreen(canWrite: true),
        ),
        waitFor: find.text('Maya Okonkwo'),
      );

      expect(find.text('Payout Queue'), findsOneWidget);
      expect(
        find.textContaining('fulfill without live PSP'),
        findsOneWidget,
      );
      expect(find.text('Mark paid'), findsOneWidget);
      expect(find.text('Reject'), findsOneWidget);
      expect(find.text('Maya Okonkwo'), findsOneWidget);
      expect(
        find.textContaining('no bank transfer'),
        findsOneWidget,
      );
    });

    testWidgets('Stitch vertical order Header → KPI → Filters → Table',
        (tester) async {
      repo.rows = [pending()];

      await pumpLocalizedApp(
        tester,
        BlocProvider(
          create: (_) => buildBloc(),
          child: const AdminPayoutQueueScreen(canWrite: true),
        ),
        waitFor: find.text('Maya Okonkwo'),
      );

      final headerY = tester.getTopLeft(find.text('Payout Queue')).dy;
      final kpiY = tester.getTopLeft(find.byType(PayoutKpiStrip)).dy;
      final filterY = tester.getTopLeft(find.byType(PayoutFilterChips)).dy;
      final tableY = tester.getTopLeft(find.byType(PayoutQueueTable)).dy;

      expect(headerY, lessThan(kpiY));
      expect(kpiY, lessThan(filterY));
      expect(filterY, lessThan(tableY));
    });


    testWidgets('Receptionist sees read-only actions', (tester) async {
      repo.rows = [pending()];

      await pumpLocalizedApp(
        tester,
        BlocProvider(
          create: (_) => buildBloc(),
          child: const AdminPayoutQueueScreen(canWrite: false),
        ),
        waitFor: find.text('Maya Okonkwo'),
      );

      expect(find.text('Mark paid'), findsNothing);
      expect(find.text('Reject'), findsNothing);
      expect(find.text('Read-only'), findsOneWidget);
    });

    testWidgets('AR RTL title renders', (tester) async {
      repo.rows = [pending()];

      await pumpLocalizedApp(
        tester,
        BlocProvider(
          create: (_) => buildBloc(),
          child: const AdminPayoutQueueScreen(canWrite: true),
        ),
        locale: AppLocales.ar,
        waitFor: find.text('تعليم كمدفوع'),
      );
      expect(find.text('طابور السحوبات'), findsOneWidget);
      expect(find.text('تعليم كمدفوع'), findsOneWidget);
      expect(find.text('رفض'), findsOneWidget);
    });
  });

  group('ports — no supabase in presentation', () {
    test('admin_payout_queue presentation sources omit supabase', () {
      final dir = Directory(
        'lib/features/admin_payout_queue/presentation',
      );
      expect(dir.existsSync(), isTrue);
      final hits = <String>[];
      for (final entity in dir.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final src = entity.readAsStringSync();
        if (src.contains('supabase_flutter')) {
          hits.add(entity.path);
        }
      }
      expect(hits, isEmpty, reason: hits.join(', '));
    });
  });
}

extension on CoachPayoutRequest {
  CoachPayoutRequest copyWithStatus(CoachPayoutRequestStatus status) {
    return CoachPayoutRequest(
      id: id,
      tenantId: tenantId,
      coachEmployeeId: coachEmployeeId,
      coachDisplayName: coachDisplayName,
      amountCents: amountCents,
      currency: currency,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now().toUtc(),
    );
  }
}
