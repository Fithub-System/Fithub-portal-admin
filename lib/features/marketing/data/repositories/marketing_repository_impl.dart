import '../../domain/entities/marketing_campaign.dart';
import '../../domain/entities/promo_code.dart';
import '../../domain/repositories/marketing_repository.dart';
import '../data_sources/remote/marketing_remote_data_source.dart';

class MarketingRepositoryImpl implements MarketingRepository {
  MarketingRepositoryImpl({required MarketingRemoteDataSource remote})
    : _remote = remote;

  final MarketingRemoteDataSource _remote;

  @override
  Future<List<MarketingCampaign>> listCampaigns() => _remote.listCampaigns();

  @override
  Future<List<PromoCode>> listPromoCodes() => _remote.listPromoCodes();

  @override
  Future<MarketingCampaign> upsertCampaign({
    String? id,
    required String name,
    required DateTime startsAt,
    required DateTime endsAt,
    required bool pushEnabled,
    String status = 'scheduled',
  }) {
    return _remote.upsertCampaign(
      id: id,
      name: name,
      startsAt: startsAt,
      endsAt: endsAt,
      pushEnabled: pushEnabled,
      status: status,
    );
  }

  @override
  Future<PromoCode> upsertPromoCode({
    String? id,
    required String code,
    int? percentOff,
    int? amountOffCents,
    String currency = 'EGP',
    DateTime? expiresAt,
    String status = 'active',
  }) {
    return _remote.upsertPromoCode(
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
