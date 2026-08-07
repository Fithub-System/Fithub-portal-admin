/// Stitch Marketing & Promotions fixtures (AC-D1 / AC-D2).
///
/// EN `c3207a6938bf40a7872dde7532020ef9` · AR `ced3126ee9584f86b8c0877d4b20a8d8`.
abstract final class MarketingStitchFixtures {
  static const String stitchScreenIdEn = 'c3207a6938bf40a7872dde7532020ef9';
  static const String stitchScreenIdAr = 'ced3126ee9584f86b8c0877d4b20a8d8';
  static const String stitchTitle = 'Marketing & Promotions';

  static const String conversionRate = '42.8%';
  static const List<String> conversionAxis = [
    'MON',
    'WED',
    'FRI',
    'SUN (TODAY)',
  ];

  /// Approximate 7-day stream heights (0–1) for Conversion Flow chrome.
  static const List<double> conversionSeries = [
    0.35,
    0.42,
    0.38,
    0.55,
    0.48,
    0.62,
    0.78,
  ];

  static const String totalReach = '1.4M';
  static const String avgClickThrough = '12.4%';
  static const String revenueAttributed = '\$48.2K';

  static const String assetLibraryCaptionKey = 'marketing.asset.caption';
  static const String assetLibraryReadyKey = 'marketing.asset.ready';

  /// Sample promo chrome when Backend list is empty (structure matches Stitch).
  static const List<Map<String, Object?>> samplePromos = [
    {
      'code': 'ALPHA30',
      'badge': '30% OFF',
      'expiry': 'Expires in 4 days',
      'redeemed': 1248,
      'status': 'active',
    },
    {
      'code': 'FOUNDER2024',
      'badge': 'LIFETIME',
      'expiry': 'No expiry',
      'redeemed': 84,
      'status': 'active',
    },
    {
      'code': 'BOLT_SPRING',
      'badge': 'EXPIRED',
      'expiry': 'Inactive since May 12',
      'redeemed': 3110,
      'status': 'expired',
    },
  ];
}
