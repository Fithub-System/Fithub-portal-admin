import 'package:flutter/material.dart';

/// Kinetic Monolith tokens from Stitch project `13435235862240753621`.
///
/// Primary occupancy screen: **Admin Overview Dashboard**
/// `screens/216e0407184f4c39bd501ed436c1e88b` (exported HTML + theme JSON).
abstract final class KineticTokens {
  /// Stitch `namedColors.background` ≈ `#131313`; FEAT-01 deep charcoal.
  static const Color deepCharcoal = Color(0xFF121212);
  static const Color stitchBackground = Color(0xFF131313);

  /// Neon lime — Stitch customColor / FEAT-01.
  static const Color electricLime = Color(0xFFCCFF00);

  /// Stitch `primary_container` / Daily Yield card fill.
  static const Color primaryContainer = Color(0xFFC3F400);

  /// Legacy gunmetal card (Phase 1.2 ring); Stitch surface-low is preferred.
  static const Color gunmetalCard = Color(0xFF1A1A1A);

  /// Stitch surface container for Live Occupancy card.
  static const Color surfaceContainerLow = Color(0xFF1C1B1B);

  static const Color zincGray = Color(0xFF6E6E73);
  static const Color cyberBlue = Color(0xFF007BFF);

  /// Stitch `secondary_container` — Live Occupancy accents / count.
  static const Color secondaryContainer = Color(0xFF4A8EFF);

  /// Stitch secondary (subtitle).
  static const Color secondaryFixedDim = Color(0xFFADC7FF);

  static const Color onSurface = Color(0xFFE5E2E1);
  static const Color neutralTrack = Color(0xFF262626);
  static const Color pureWhite = Color(0xFFFFFFFF);

  static const double safeModeBannerHeight = 24;

  /// Stitch card uses Tailwind `rounded-xl` (= 12).
  static const double dashboardCardRadius = 12;
  static const double occupancyCardAccentWidth = 4;
  static const double occupancyProgressHeight = 16;

  /// Retained for legacy ring painter tests / SafeMode carry-forward.
  static const double occupancyRingSize = 220;
  static const double occupancyRingStroke = 12;
  static const double occupancyGlowBlur = 20;

  /// Translation key — use `'connectivity.safe_mode.banner'.tr()` in UI.
  static const String safeModeMessageKey = 'connectivity.safe_mode.banner';

  /// Cited Stitch screen for Live Occupancy (Verification Audit).
  static const String stitchOccupancyScreenId =
      '216e0407184f4c39bd501ed436c1e88b';

  /// Cited Stitch screen for Invite Staff / Staff Profile Creator (FEAT-05).
  static const String stitchStaffInviteScreenId =
      'dcc070ef2b1e45058b3e042ad70140e3';
  static const String stitchProjectId = '13435235862240753621';
}
