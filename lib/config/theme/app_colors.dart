import 'package:flutter/material.dart';

/// Stitch Kinetic Monolith tokens from project `13435235862240753621`
/// (`get_project.designTheme.namedColors` + Web Admin Login Portal screen
/// `projects/.../screens/c12b687f1538452ebaf8d0adb89a9489`).
abstract final class AppColors {
  // Surfaces
  static const Color background = Color(0xFF131313);
  static const Color surface = Color(0xFF131313);
  static const Color surfaceContainerLow = Color(0xFF1C1B1B);
  static const Color surfaceContainer = Color(0xFF201F1F);
  static const Color surfaceContainerHigh = Color(0xFF2A2A2A);
  static const Color surfaceContainerHighest = Color(0xFF353534);
  static const Color surfaceContainerLowest = Color(0xFF0E0E0E);
  static const Color surfaceBright = Color(0xFF393939);

  // Kinetic trigger (CTA)
  static const Color primaryContainer = Color(0xFFC3F400);
  static const Color primaryFixedDim = Color(0xFFABD600);
  static const Color onPrimaryContainer = Color(0xFF556D00);
  static const Color onPrimary = Color(0xFF283500);
  static const Color primary = Color(0xFFFFFFFF);

  // FEAT-02 locked brand accent (customColor seed)
  static const Color electricLime = Color(0xFFCCFF00);
  static const Color deepCharcoal = Color(0xFF121212);

  // Text / outline
  static const Color onSurface = Color(0xFFE5E2E1);
  static const Color onSurfaceVariant = Color(0xFFC4C9AC);
  static const Color outline = Color(0xFF8E9379);
  static const Color outlineVariant = Color(0xFF444933);
  static const Color zinc500 = Color(0xFF71717A);
  static const Color pureWhite = Color(0xFFFFFFFF);

  // Secondary / links
  static const Color secondary = Color(0xFFADC7FF);
  static const Color secondaryFixed = Color(0xFFD8E2FF);
  static const Color secondaryContainer = Color(0xFF4A8EFF);

  // Error snackbar (Stitch namedColors)
  static const Color error = Color(0xFFFFB4AB);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onErrorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFF690005);

  static const LinearGradient kineticCta = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryContainer, primaryFixedDim],
  );
}
