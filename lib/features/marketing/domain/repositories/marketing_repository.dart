import '../entities/marketing_campaign.dart';
import '../entities/promo_code.dart';

abstract class MarketingRepository {
  Future<List<MarketingCampaign>> listCampaigns();

  Future<List<PromoCode>> listPromoCodes();

  Future<MarketingCampaign> upsertCampaign({
    String? id,
    required String name,
    required DateTime startsAt,
    required DateTime endsAt,
    required bool pushEnabled,
    String status = 'scheduled',
  });

  Future<PromoCode> upsertPromoCode({
    String? id,
    required String code,
    int? percentOff,
    int? amountOffCents,
    String currency = 'EGP',
    DateTime? expiresAt,
    String status = 'active',
  });
}
