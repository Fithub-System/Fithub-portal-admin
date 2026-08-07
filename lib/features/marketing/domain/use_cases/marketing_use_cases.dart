import '../../../../core/network/cloud_mutation_guard.dart';
import '../entities/marketing_campaign.dart';
import '../entities/promo_code.dart';
import '../marketing_failure.dart';
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
  UpsertMarketingCampaignUseCase(
    this._repository, {
    required CloudMutationGuard cloudGuard,
  }) : _cloudGuard = cloudGuard;

  final MarketingRepository _repository;
  final CloudMutationGuard _cloudGuard;

  Future<MarketingCampaign> call({
    String? id,
    required String name,
    required DateTime startsAt,
    required DateTime endsAt,
    required bool pushEnabled,
    String status = 'scheduled',
  }) {
    if (!_cloudGuard.isOnline) {
      throw const MarketingOfflineFailure();
    }
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
  UpsertPromoCodeUseCase(
    this._repository, {
    required CloudMutationGuard cloudGuard,
  }) : _cloudGuard = cloudGuard;

  final MarketingRepository _repository;
  final CloudMutationGuard _cloudGuard;

  Future<PromoCode> call({
    String? id,
    required String code,
    int? percentOff,
    int? amountOffCents,
    String currency = 'EGP',
    DateTime? expiresAt,
    String status = 'active',
  }) {
    if (!_cloudGuard.isOnline) {
      throw const MarketingOfflineFailure();
    }
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
