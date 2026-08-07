import '../entities/marketing_campaign.dart';
import '../entities/promo_code.dart';
import '../repositories/marketing_repository.dart';

class ListMarketingCampaignsUseCase {
  const ListMarketingCampaignsUseCase(this._repository);
  final MarketingRepository _repository;

  Future<List<MarketingCampaign>> call() => _repository.listCampaigns();
}

class ListPromoCodesUseCase {
  const ListPromoCodesUseCase(this._repository);
  final MarketingRepository _repository;

  Future<List<PromoCode>> call() => _repository.listPromoCodes();
}

class UpsertMarketingCampaignUseCase {
  const UpsertMarketingCampaignUseCase(this._repository);
  final MarketingRepository _repository;

  Future<MarketingCampaign> call({
    String? id,
    required String name,
    required DateTime startsAt,
    required DateTime endsAt,
    required bool pushEnabled,
    String status = 'scheduled',
  }) {
    return _repository.upsertCampaign(
      id: id,
      name: name,
      startsAt: startsAt,
      endsAt: endsAt,
      pushEnabled: pushEnabled,
      status: status,
    );
  }
}

class UpsertPromoCodeUseCase {
  const UpsertPromoCodeUseCase(this._repository);
  final MarketingRepository _repository;

  Future<PromoCode> call({
    String? id,
    required String code,
    int? percentOff,
    int? amountOffCents,
    String currency = 'EGP',
    DateTime? expiresAt,
    String status = 'active',
  }) {
    return _repository.upsertPromoCode(
      id: id,
      code: code,
      percentOff: percentOff,
      amountOffCents: amountOffCents,
      currency: currency,
      expiresAt: expiresAt,
      status: status,
    );
  }
}
