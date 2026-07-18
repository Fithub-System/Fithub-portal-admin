import 'package:flutter/material.dart';

/// Verified Kinetic Monolith tokens from Stitch project `13435235862240753621`
/// and FEAT-01 Admin Portal blueprint (Section 3).
abstract final class KineticTokens {
  static const Color deepCharcoal = Color(0xFF121212);
  static const Color electricLime = Color(0xFFCCFF00);
  static const Color gunmetalCard = Color(0xFF1A1A1A);
  static const Color zincGray = Color(0xFF6E6E73);
  static const Color cyberBlue = Color(0xFF007BFF);
  static const Color pureWhite = Color(0xFFFFFFFF);

  static const double safeModeBannerHeight = 24;
  static const double occupancyRingSize = 220;
  static const double occupancyRingStroke = 12;
  static const double dashboardCardRadius = 16;
  static const double occupancyGlowBlur = 20;

  /// Translation key — use `'connectivity.safe_mode.banner'.tr()` in UI.
  static const String safeModeMessageKey = 'connectivity.safe_mode.banner';
}
