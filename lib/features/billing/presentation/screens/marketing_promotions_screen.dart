import 'package:flutter/material.dart';

import '../../../marketing/presentation/fixtures/marketing_stitch_fixtures.dart';
import '../../../marketing/presentation/screens/marketing_screen.dart';

/// FEAT-08 / FEAT-23 Marketing rail destination.
///
/// Stitch: `c3207a6938bf40a7872dde7532020ef9` (Marketing & Promotions).
/// FEAT-23: Growth Engine is primary; FEAT-08 Billing remains secondary.
class MarketingPromotionsScreen extends StatelessWidget {
  const MarketingPromotionsScreen({super.key, required this.canWrite});

  static const String stitchScreenId =
      MarketingStitchFixtures.stitchScreenIdEn;
  static const String stitchScreenTitle = MarketingStitchFixtures.stitchTitle;

  /// Admin-only campaign/promo writes + FEAT-08 mark paid/waived/freeze.
  final bool canWrite;

  @override
  Widget build(BuildContext context) {
    return MarketingScreen(canWrite: canWrite);
  }
}
