import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'kinetic_tokens.dart';

final ThemeData kineticDarkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: KineticTokens.deepCharcoal,
  colorScheme: const ColorScheme.dark(
    primary: KineticTokens.electricLime,
    secondary: KineticTokens.cyberBlue,
    surface: KineticTokens.gunmetalCard,
    onPrimary: KineticTokens.deepCharcoal,
    onSurface: KineticTokens.pureWhite,
  ),
  textTheme: GoogleFonts.lexendTextTheme(ThemeData.dark().textTheme),
  cardTheme: CardThemeData(
    color: KineticTokens.gunmetalCard,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(KineticTokens.dashboardCardRadius),
    ),
  ),
  useMaterial3: true,
);

/// Backward-compatible alias for starter-kit theme manager.
final ThemeData darkTheme = kineticDarkTheme;
