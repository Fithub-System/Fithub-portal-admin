import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fithub_portal_admin/features/auth/domain/entities/employee_profile.dart';
import 'package:fithub_portal_admin/features/billing/presentation/screens/marketing_promotions_screen.dart';
import 'package:fithub_portal_admin/features/home/presentation/pages/portal_shell_destinations.dart';
import 'package:fithub_portal_admin/features/marketing/domain/entities/marketing_campaign.dart';
import 'package:fithub_portal_admin/features/marketing/domain/entities/promo_code.dart';
import 'package:fithub_portal_admin/features/marketing/domain/marketing_failure.dart';
import 'package:fithub_portal_admin/features/marketing/domain/repositories/marketing_repository.dart';
import 'package:fithub_portal_admin/features/marketing/domain/use_cases/marketing_use_cases.dart';
import 'package:fithub_portal_admin/features/marketing/presentation/bloc/marketing_bloc.dart';
import 'package:fithub_portal_admin/features/marketing/presentation/fixtures/marketing_stitch_fixtures.dart';
import 'package:fithub_portal_admin/features/marketing/presentation/screens/marketing_screen.dart';
import 'package:fithub_portal_admin/features/marketing/presentation/widgets/active_promos_panel.dart';
import 'package:fithub_portal_admin/features/marketing/presentation/widgets/flash_sale_campaign_form.dart';
import 'package:fithub_portal_admin/features/marketing/presentation/widgets/marketing_analytics_chrome.dart';
import 'package:mocktail/mocktail.dart';

import 'support/localized_pump.dart';

class _MockMarketingRepo extends Mock implements MarketingRepository {}

void main() {
  late _MockMarketingRepo marketingRepo;

  setUpAll(() {
    registerFallbackValue(DateTime(2026, 1, 1));
  });

  setUp(() {
    marketingRepo = _MockMarketingRepo();
  });

  MarketingBloc buildMarketingBloc() {
    return MarketingBloc(
      listCampaigns: ListMarketingCampaignsUseCase(marketingRepo),
      listPromoCodes: ListPromoCodesUseCase(marketingRepo),
      upsertCampaign: UpsertMarketingCampaignUseCase(marketingRepo),
      upsertPromoCode: UpsertPromoCodeUseCase(marketingRepo),
    );
  }

  group('FEAT-23 Admin gate', () {
    test('Admin can manage marketing; Receptionist cannot', () {
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
      expect(admin.canManageMarketing, isTrue);
      expect(receptionist.canManageMarketing, isFalse);
      expect(admin.canManageBilling, isTrue);
    });
  });

  group('MarketingBloc', () {
    test('load emits ready with campaigns and promos', () async {
      when(() => marketingRepo.listCampaigns()).thenAnswer(
        (_) async => [
          MarketingCampaign(
            id: 'c1',
            tenantId: 't1',
            name: 'Flash Sale',
            startsAt: DateTime.utc(2026, 8, 8),
            endsAt: DateTime.utc(2026, 8, 10),
            pushEnabled: true,
            status: 'scheduled',
          ),
        ],
      );
      when(() => marketingRepo.listPromoCodes()).thenAnswer(
        (_) async => [
          const PromoCode(
            id: 'p1',
            tenantId: 't1',
            code: 'ALPHA30',
            percentOff: 30,
            currency: 'EGP',
            status: 'active',
            redeemedCount: 0,
          ),
        ],
      );

      final bloc = buildMarketingBloc();
      bloc.add(const MarketingLoadRequested());
      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<MarketingState>(
            (s) =>
                s.status == MarketingStatus.ready &&
                s.campaigns.length == 1 &&
                s.promoCodes.length == 1,
          ),
        ),
      );
      await bloc.close();
    });

    test('deploy maps forbidden failure to message key', () async {
      when(() => marketingRepo.listCampaigns()).thenAnswer((_) async => []);
      when(() => marketingRepo.listPromoCodes()).thenAnswer((_) async => []);
      when(
        () => marketingRepo.upsertCampaign(
          id: any(named: 'id'),
          name: any(named: 'name'),
          startsAt: any(named: 'startsAt'),
          endsAt: any(named: 'endsAt'),
          pushEnabled: any(named: 'pushEnabled'),
          status: any(named: 'status'),
        ),
      ).thenThrow(const MarketingForbiddenFailure());

      final bloc = buildMarketingBloc();
      final loaded = bloc.stream.firstWhere(
        (s) => s.status == MarketingStatus.ready,
      );
      bloc.add(const MarketingLoadRequested());
      await loaded;

      bloc.add(
        MarketingDeployCampaignRequested(
          name: 'Summer',
          startsAt: DateTime.utc(2026, 8, 8),
          endsAt: DateTime.utc(2026, 8, 10),
          pushEnabled: true,
        ),
      );
      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<MarketingState>(
            (s) => s.messageKey == 'marketing.error.forbidden',
          ),
        ),
      );
      await bloc.close();
    });

    test('create promo validates XOR discount shape', () async {
      when(() => marketingRepo.listCampaigns()).thenAnswer((_) async => []);
      when(() => marketingRepo.listPromoCodes()).thenAnswer((_) async => []);

      final bloc = buildMarketingBloc();
      final loaded = bloc.stream.firstWhere(
        (s) => s.status == MarketingStatus.ready,
      );
      bloc.add(const MarketingLoadRequested());
      await loaded;

      bloc.add(const MarketingCreatePromoRequested(code: 'X'));
      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<MarketingState>(
            (s) => s.messageKey == 'marketing.error.invalid',
          ),
        ),
      );
      await bloc.close();
    });
  });

  group('FEAT-23 Stitch citations', () {
    test('Marketing cites locked EN + AR ids', () {
      expect(
        MarketingScreen.stitchScreenIdEn,
        'c3207a6938bf40a7872dde7532020ef9',
      );
      expect(
        MarketingScreen.stitchScreenIdAr,
        'ced3126ee9584f86b8c0877d4b20a8d8',
      );
      expect(
        MarketingPromotionsScreen.stitchScreenId,
        MarketingStitchFixtures.stitchScreenIdEn,
      );
      expect(MarketingStitchFixtures.totalReach, '1.4M');
      expect(PortalShellDestinations.marketing, 4);
      expect(PortalShellDestinations.destinationCount, 6);
    });
  });

  group('FEAT-23 Growth Engine regions', () {
    testWidgets('Admin Flash Sale + promos + analytics chrome', (tester) async {
      final nameController = TextEditingController();
      addTearDown(nameController.dispose);

      await pumpLocalizedApp(
        tester,
        Scaffold(
          body: Builder(
            builder: (context) {
              return ListView(
                children: [
                  Text('marketing.growth_engine'.tr()),
                  Text('marketing.billing_secondary_title'.tr()),
                  FlashSaleCampaignForm(
                    canWrite: true,
                    busy: false,
                    nameController: nameController,
                    startsAt: null,
                    endsAt: null,
                    pushEnabled: true,
                    onPickStart: () {},
                    onPickEnd: () {},
                    onPushChanged: (_) {},
                    onDeploy: () {},
                  ),
                  const ConversionFlowCard(),
                  const AssetLibraryCard(),
                  ActivePromosPanel(
                    canWrite: true,
                    busy: false,
                    promoCodes: const [],
                    onCreate: () {},
                  ),
                  const MarketingMetricTiles(),
                ],
              );
            },
          ),
        ),
        waitFor: find.textContaining('FLASH SALE'),
      );

      expect(find.textContaining('GROWTH ENGINE'), findsOneWidget);
      expect(find.textContaining('DEPLOY CAMPAIGN'), findsOneWidget);
      expect(find.textContaining('ACTIVE PROMOS'), findsOneWidget);
      expect(find.textContaining('Create New Code'), findsOneWidget);
      expect(find.textContaining('CONVERSION FLOW'), findsOneWidget);
      expect(find.textContaining('ASSET LIBRARY'), findsOneWidget);
      expect(find.textContaining('TOTAL REACH'), findsOneWidget);
      expect(find.textContaining('BILLING / CHARGES'), findsOneWidget);
      expect(find.textContaining('ALPHA30'), findsOneWidget);

      final deploy = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'DEPLOY CAMPAIGN'),
      );
      expect(deploy.onPressed, isNotNull);
    });

    testWidgets('Receptionist disables deploy CTA', (tester) async {
      final nameController = TextEditingController();
      addTearDown(nameController.dispose);

      await pumpLocalizedApp(
        tester,
        Scaffold(
          body: FlashSaleCampaignForm(
            canWrite: false,
            busy: false,
            nameController: nameController,
            startsAt: null,
            endsAt: null,
            pushEnabled: true,
            onPickStart: () {},
            onPickEnd: () {},
            onPushChanged: (_) {},
            onDeploy: () {},
          ),
        ),
        waitFor: find.textContaining('FLASH SALE'),
      );

      final deploy = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'DEPLOY CAMPAIGN'),
      );
      expect(deploy.onPressed, isNull);
      expect(find.textContaining('Receptionist view'), findsOneWidget);
    });
  });
}
