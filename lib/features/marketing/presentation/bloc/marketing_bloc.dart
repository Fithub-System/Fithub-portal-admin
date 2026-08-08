import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/marketing_campaign.dart';
import '../../domain/entities/promo_code.dart';
import '../../domain/marketing_failure.dart';
import '../../domain/use_cases/marketing_use_cases.dart';

part 'marketing_event.dart';
part 'marketing_state.dart';

class MarketingBloc extends Bloc<MarketingEvent, MarketingState> {
  MarketingBloc({
    required ListMarketingCampaignsUseCase listCampaigns,
    required ListPromoCodesUseCase listPromoCodes,
    required UpsertMarketingCampaignUseCase upsertCampaign,
    required UpsertPromoCodeUseCase upsertPromoCode,
  }) : _listCampaigns = listCampaigns,
       _listPromoCodes = listPromoCodes,
       _upsertCampaign = upsertCampaign,
       _upsertPromoCode = upsertPromoCode,
       super(const MarketingState()) {
    on<MarketingLoadRequested>(_onLoad);
    on<MarketingDeployCampaignRequested>(_onDeploy);
    on<MarketingSoftEndCampaignRequested>(_onSoftEnd);
    on<MarketingCreatePromoRequested>(_onCreatePromo);
    on<MarketingMessageCleared>(_onClearMessage);
  }

  final ListMarketingCampaignsUseCase _listCampaigns;
  final ListPromoCodesUseCase _listPromoCodes;
  final UpsertMarketingCampaignUseCase _upsertCampaign;
  final UpsertPromoCodeUseCase _upsertPromoCode;

  Future<void> _onLoad(
    MarketingLoadRequested event,
    Emitter<MarketingState> emit,
  ) async {
    emit(state.copyWith(status: MarketingStatus.loading, clearMessage: true));
    try {
      final campaigns = await _listCampaigns();
      final promos = await _listPromoCodes();
      emit(
        state.copyWith(
          status: MarketingStatus.ready,
          campaigns: campaigns,
          promoCodes: promos,
        ),
      );
    } on MarketingFailure catch (e) {
      emit(
        state.copyWith(
          status: MarketingStatus.failure,
          messageKey: e.messageKey,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: MarketingStatus.failure,
          messageKey: const MarketingUnknownFailure().messageKey,
        ),
      );
    }
  }

  Future<void> _onDeploy(
    MarketingDeployCampaignRequested event,
    Emitter<MarketingState> emit,
  ) async {
    final name = event.name.trim();
    if (name.isEmpty || !event.endsAt.isAfter(event.startsAt)) {
      emit(
        state.copyWith(
          messageKey: const MarketingValidationFailure().messageKey,
        ),
      );
      return;
    }

    emit(state.copyWith(busy: true, clearMessage: true));
    try {
      final now = DateTime.now().toUtc();
      final status =
          !event.startsAt.toUtc().isAfter(now) &&
              event.endsAt.toUtc().isAfter(now)
          ? 'active'
          : 'scheduled';
      await _upsertCampaign(
        name: name,
        startsAt: event.startsAt,
        endsAt: event.endsAt,
        pushEnabled: event.pushEnabled,
        status: status,
      );
      final campaigns = await _listCampaigns();
      emit(
        state.copyWith(
          busy: false,
          campaigns: campaigns,
          messageKey: 'marketing.success.campaign_deployed',
        ),
      );
    } on MarketingFailure catch (e) {
      emit(state.copyWith(busy: false, messageKey: e.messageKey));
    } catch (_) {
      emit(
        state.copyWith(
          busy: false,
          messageKey: const MarketingUnknownFailure().messageKey,
        ),
      );
    }
  }

  Future<void> _onSoftEnd(
    MarketingSoftEndCampaignRequested event,
    Emitter<MarketingState> emit,
  ) async {
    emit(state.copyWith(busy: true, clearMessage: true));
    try {
      await _upsertCampaign(
        id: event.campaign.id,
        name: event.campaign.name,
        startsAt: event.campaign.startsAt,
        endsAt: event.campaign.endsAt,
        pushEnabled: event.campaign.pushEnabled,
        status: event.status,
      );
      final campaigns = await _listCampaigns();
      emit(
        state.copyWith(
          busy: false,
          campaigns: campaigns,
          messageKey: 'marketing.success.campaign_ended',
        ),
      );
    } on MarketingFailure catch (e) {
      emit(state.copyWith(busy: false, messageKey: e.messageKey));
    } catch (_) {
      emit(
        state.copyWith(
          busy: false,
          messageKey: const MarketingUnknownFailure().messageKey,
        ),
      );
    }
  }

  Future<void> _onCreatePromo(
    MarketingCreatePromoRequested event,
    Emitter<MarketingState> emit,
  ) async {
    final code = event.code.trim();
    final hasPercent = event.percentOff != null;
    final hasAmount = event.amountOffCents != null;
    if (code.isEmpty || hasPercent == hasAmount) {
      emit(
        state.copyWith(
          messageKey: const MarketingValidationFailure().messageKey,
        ),
      );
      return;
    }
    if (hasPercent && (event.percentOff! < 1 || event.percentOff! > 100)) {
      emit(
        state.copyWith(
          messageKey: const MarketingValidationFailure().messageKey,
        ),
      );
      return;
    }

    emit(state.copyWith(busy: true, clearMessage: true));
    try {
      await _upsertPromoCode(
        code: code,
        percentOff: event.percentOff,
        amountOffCents: event.amountOffCents,
        currency: event.currency,
        expiresAt: event.expiresAt,
        status: 'active',
      );
      final promos = await _listPromoCodes();
      emit(
        state.copyWith(
          busy: false,
          promoCodes: promos,
          messageKey: 'marketing.success.promo_created',
        ),
      );
    } on MarketingFailure catch (e) {
      emit(state.copyWith(busy: false, messageKey: e.messageKey));
    } catch (_) {
      emit(
        state.copyWith(
          busy: false,
          messageKey: const MarketingUnknownFailure().messageKey,
        ),
      );
    }
  }

  void _onClearMessage(
    MarketingMessageCleared event,
    Emitter<MarketingState> emit,
  ) {
    emit(state.copyWith(clearMessage: true));
  }
}
