import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fithub_portal_admin/config/theme/kinetic_tokens.dart';
import 'package:fithub_portal_admin/features/auth/domain/entities/employee_profile.dart';
import 'package:fithub_portal_admin/features/gym_sku_settings/domain/entities/gym_sku_settings.dart';
import 'package:fithub_portal_admin/features/gym_sku_settings/domain/gym_sku_settings_failure.dart';
import 'package:fithub_portal_admin/features/gym_sku_settings/domain/repositories/gym_sku_settings_repository.dart';
import 'package:fithub_portal_admin/features/gym_sku_settings/domain/use_cases/gym_sku_settings_use_case.dart';
import 'package:fithub_portal_admin/features/gym_sku_settings/presentation/bloc/gym_sku_settings_bloc.dart';
import 'package:fithub_portal_admin/features/gym_sku_settings/presentation/screens/gym_sku_settings_screen.dart';
import 'package:fithub_portal_admin/features/home/presentation/pages/portal_shell_destinations.dart';
import 'package:fithub_portal_admin/features/home/presentation/widgets/kinetic_coming_soon_empty.dart';
import 'package:mocktail/mocktail.dart';

import 'support/localized_pump.dart';

class _MockGymSkuRepo extends Mock implements GymSkuSettingsRepository {}

Future<void> _waitReady(GymSkuSettingsBloc bloc) async {
  if (bloc.state.status == GymSkuSettingsStatus.ready) return;
  await bloc.stream.firstWhere((s) => s.status == GymSkuSettingsStatus.ready);
}

void main() {
  late _MockGymSkuRepo repository;

  setUpAll(() {
    registerFallbackValue(SkuMode.privateCloud);
  });

  setUp(() {
    repository = _MockGymSkuRepo();
  });

  group('FEAT-10 Admin gate', () {
    test('Admin can manage SKU; Receptionist cannot', () {
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
      expect(admin.canManageSkuSettings, isTrue);
      expect(receptionist.canManageSkuSettings, isFalse);
    });
  });

  group('FEAT-10 Stitch citations', () {
    test('Gym Settings cites locked G2 EN + AR ids', () {
      expect(
        GymSkuSettingsScreen.stitchScreenId,
        '6cb93d6100314ce8a5d9c1af92c97723',
      );
      expect(
        GymSkuSettingsScreen.stitchScreenIdAr,
        '9541b6e764dd436daa91336b0ce2263b',
      );
      expect(
        KineticTokens.stitchGymSettingsScreenId,
        GymSkuSettingsScreen.stitchScreenId,
      );
      expect(
        KineticTokens.stitchGymSettingsScreenIdAr,
        GymSkuSettingsScreen.stitchScreenIdAr,
      );
    });

    test('six rail destinations preserved (not a 7th Settings tab)', () {
      expect(PortalShellDestinations.destinationCount, 6);
      expect(PortalShellDestinations.reports, 5);
    });
  });

  group('SkuMode', () {
    test('fromApi / apiValue round-trip', () {
      expect(SkuMode.fromApi('network'), SkuMode.network);
      expect(SkuMode.fromApi('private_cloud'), SkuMode.privateCloud);
      expect(SkuMode.network.apiValue, 'network');
      expect(SkuMode.privateCloud.apiValue, 'private_cloud');
      expect(SkuMode.privateCloud.allowsMarketplaceOptIn, isFalse);
      expect(SkuMode.network.allowsMarketplaceOptIn, isTrue);
    });
  });

  group('SetGymSkuSettingsUseCase', () {
    test('forces marketplace opt-in false for private_cloud', () async {
      when(
        () => repository.setSettings(
          skuMode: SkuMode.privateCloud,
          marketplaceOptIn: false,
        ),
      ).thenAnswer(
        (_) async => const GymSkuSettings(
          id: 'g1',
          skuMode: SkuMode.privateCloud,
          marketplaceOptIn: false,
        ),
      );

      final useCase = SetGymSkuSettingsUseCase(repository);
      final result = await useCase(
        skuMode: SkuMode.privateCloud,
        marketplaceOptIn: true,
      );

      expect(result.marketplaceOptIn, isFalse);
      verify(
        () => repository.setSettings(
          skuMode: SkuMode.privateCloud,
          marketplaceOptIn: false,
        ),
      ).called(1);
    });
  });

  group('GymSkuSettingsBloc', () {
    test('load emits ready with draft from saved settings', () async {
      when(() => repository.getSettings()).thenAnswer(
        (_) async => const GymSkuSettings(
          id: 'g1',
          skuMode: SkuMode.network,
          marketplaceOptIn: true,
        ),
      );
      final bloc = GymSkuSettingsBloc(
        getSettings: GetGymSkuSettingsUseCase(repository),
        setSettings: SetGymSkuSettingsUseCase(repository),
      );

      bloc.add(const GymSkuSettingsLoadRequested());
      await _waitReady(bloc);
      expect(bloc.state.status, GymSkuSettingsStatus.ready);
      expect(bloc.state.draftSkuMode, SkuMode.network);
      expect(bloc.state.draftMarketplaceOptIn, isTrue);
      await bloc.close();
    });

    test('switching to private_cloud clears draft marketplace opt-in', () async {
      when(() => repository.getSettings()).thenAnswer(
        (_) async => const GymSkuSettings(
          id: 'g1',
          skuMode: SkuMode.network,
          marketplaceOptIn: true,
        ),
      );
      final bloc = GymSkuSettingsBloc(
        getSettings: GetGymSkuSettingsUseCase(repository),
        setSettings: SetGymSkuSettingsUseCase(repository),
      );

      bloc.add(const GymSkuSettingsLoadRequested());
      await _waitReady(bloc);
      bloc.add(const GymSkuSettingsSkuModeChanged(SkuMode.privateCloud));
      await bloc.stream.first;
      expect(bloc.state.draftSkuMode, SkuMode.privateCloud);
      expect(bloc.state.draftMarketplaceOptIn, isFalse);
      expect(bloc.state.marketplaceToggleEnabled, isFalse);
      await bloc.close();
    });

    test('save calls setSettings (RPC path) and emits success', () async {
      when(() => repository.getSettings()).thenAnswer(
        (_) async => const GymSkuSettings(
          id: 'g1',
          skuMode: SkuMode.privateCloud,
          marketplaceOptIn: false,
        ),
      );
      when(
        () => repository.setSettings(
          skuMode: any(named: 'skuMode'),
          marketplaceOptIn: any(named: 'marketplaceOptIn'),
        ),
      ).thenAnswer(
        (_) async => const GymSkuSettings(
          id: 'g1',
          skuMode: SkuMode.network,
          marketplaceOptIn: true,
        ),
      );
      final bloc = GymSkuSettingsBloc(
        getSettings: GetGymSkuSettingsUseCase(repository),
        setSettings: SetGymSkuSettingsUseCase(repository),
      );

      bloc.add(const GymSkuSettingsLoadRequested());
      await _waitReady(bloc);
      bloc.add(const GymSkuSettingsSkuModeChanged(SkuMode.network));
      await bloc.stream.first;
      bloc.add(const GymSkuSettingsMarketplaceChanged(true));
      await bloc.stream.first;
      bloc.add(const GymSkuSettingsSaveRequested());
      await bloc.stream.firstWhere(
        (s) => s.messageKey == 'gym_settings.success.saved',
      );
      expect(bloc.state.busy, isFalse);
      expect(bloc.state.draftSkuMode, SkuMode.network);
      expect(bloc.state.draftMarketplaceOptIn, isTrue);
      verify(
        () => repository.setSettings(
          skuMode: SkuMode.network,
          marketplaceOptIn: true,
        ),
      ).called(1);
      await bloc.close();
    });

    test('forbidden save surfaces message key', () async {
      when(() => repository.getSettings()).thenAnswer(
        (_) async => const GymSkuSettings(
          id: 'g1',
          skuMode: SkuMode.privateCloud,
          marketplaceOptIn: false,
        ),
      );
      when(
        () => repository.setSettings(
          skuMode: any(named: 'skuMode'),
          marketplaceOptIn: any(named: 'marketplaceOptIn'),
        ),
      ).thenThrow(const GymSkuSettingsForbiddenFailure());
      final bloc = GymSkuSettingsBloc(
        getSettings: GetGymSkuSettingsUseCase(repository),
        setSettings: SetGymSkuSettingsUseCase(repository),
      );

      bloc.add(const GymSkuSettingsLoadRequested());
      await _waitReady(bloc);
      bloc.add(const GymSkuSettingsSkuModeChanged(SkuMode.network));
      await bloc.stream.first;
      bloc.add(const GymSkuSettingsSaveRequested());
      await bloc.stream.firstWhere(
        (s) => s.messageKey == 'gym_settings.error.forbidden',
      );
      expect(bloc.state.busy, isFalse);
      await bloc.close();
    });
  });

  group('FEAT-10 Reports nest smoke', () {
    testWidgets('ReportsShellPage shows Gym Settings entry EN', (tester) async {
      var opened = false;
      await pumpLocalizedApp(
        tester,
        ReportsShellPage(onOpenGymSettings: () => opened = true),
      );
      expect(find.text('Gym Settings'), findsOneWidget);
      await tester.tap(find.text('Gym Settings'));
      await tester.pump();
      expect(opened, isTrue);
    });

    testWidgets('ReportsShellPage AR shows settings nest', (tester) async {
      await pumpLocalizedApp(
        tester,
        ReportsShellPage(onOpenGymSettings: () {}),
        locale: const Locale('ar'),
      );
      expect(find.text('إعدادات الصالة'), findsOneWidget);
    });
  });
}
