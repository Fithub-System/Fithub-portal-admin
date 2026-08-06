import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/gym_sku_settings.dart';
import '../../domain/gym_sku_settings_failure.dart';
import '../../domain/use_cases/gym_sku_settings_use_case.dart';

part 'gym_sku_settings_event.dart';
part 'gym_sku_settings_state.dart';

class GymSkuSettingsBloc
    extends Bloc<GymSkuSettingsEvent, GymSkuSettingsState> {
  GymSkuSettingsBloc({
    required GetGymSkuSettingsUseCase getSettings,
    required SetGymSkuSettingsUseCase setSettings,
  }) : _getSettings = getSettings,
       _setSettings = setSettings,
       super(const GymSkuSettingsState()) {
    on<GymSkuSettingsLoadRequested>(_onLoad);
    on<GymSkuSettingsSkuModeChanged>(_onSkuModeChanged);
    on<GymSkuSettingsMarketplaceChanged>(_onMarketplaceChanged);
    on<GymSkuSettingsSaveRequested>(_onSave);
  }

  final GetGymSkuSettingsUseCase _getSettings;
  final SetGymSkuSettingsUseCase _setSettings;

  Future<void> _onLoad(
    GymSkuSettingsLoadRequested event,
    Emitter<GymSkuSettingsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: GymSkuSettingsStatus.loading,
        clearMessage: true,
      ),
    );
    try {
      final settings = await _getSettings();
      emit(
        state.copyWith(
          status: GymSkuSettingsStatus.ready,
          saved: settings,
          draftSkuMode: settings.skuMode,
          draftMarketplaceOptIn: settings.effectiveMarketplaceOptIn,
        ),
      );
    } on GymSkuSettingsFailure catch (e) {
      emit(
        state.copyWith(
          status: GymSkuSettingsStatus.failure,
          messageKey: e.messageKey,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: GymSkuSettingsStatus.failure,
          messageKey: const GymSkuSettingsUnknownFailure().messageKey,
        ),
      );
    }
  }

  void _onSkuModeChanged(
    GymSkuSettingsSkuModeChanged event,
    Emitter<GymSkuSettingsState> emit,
  ) {
    final mode = event.skuMode;
    final optIn = mode.allowsMarketplaceOptIn
        ? state.draftMarketplaceOptIn
        : false;
    emit(
      state.copyWith(
        draftSkuMode: mode,
        draftMarketplaceOptIn: optIn,
        clearMessage: true,
      ),
    );
  }

  void _onMarketplaceChanged(
    GymSkuSettingsMarketplaceChanged event,
    Emitter<GymSkuSettingsState> emit,
  ) {
    if (!state.draftSkuMode.allowsMarketplaceOptIn) return;
    emit(
      state.copyWith(
        draftMarketplaceOptIn: event.optIn,
        clearMessage: true,
      ),
    );
  }

  Future<void> _onSave(
    GymSkuSettingsSaveRequested event,
    Emitter<GymSkuSettingsState> emit,
  ) async {
    emit(state.copyWith(busy: true, clearMessage: true));
    try {
      final saved = await _setSettings(
        skuMode: state.draftSkuMode,
        marketplaceOptIn: state.draftMarketplaceOptIn,
      );
      emit(
        state.copyWith(
          busy: false,
          status: GymSkuSettingsStatus.ready,
          saved: saved,
          draftSkuMode: saved.skuMode,
          draftMarketplaceOptIn: saved.effectiveMarketplaceOptIn,
          messageKey: 'gym_settings.success.saved',
        ),
      );
    } on GymSkuSettingsFailure catch (e) {
      emit(state.copyWith(busy: false, messageKey: e.messageKey));
    } catch (_) {
      emit(
        state.copyWith(
          busy: false,
          messageKey: const GymSkuSettingsUnknownFailure().messageKey,
        ),
      );
    }
  }
}
