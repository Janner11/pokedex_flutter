import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tema global Material 3
ThemeData appTheme() {
  const pokedexRed = Color(0xFFE3350D);
  const accentBlue = Color(0xFF6493EB);
  const backgroundWhite = Color(0xFFF8F9FA);

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: pokedexRed,
      primary: pokedexRed,
      secondary: accentBlue,
      brightness: Brightness.light,
      background: backgroundWhite,
    ),
    textTheme: GoogleFonts.robotoFlexTextTheme().copyWith(
      titleLarge: GoogleFonts.robotoFlex(fontWeight: FontWeight.w800),
      titleMedium: GoogleFonts.robotoFlex(fontWeight: FontWeight.w700),
      bodyMedium: GoogleFonts.robotoFlex(fontWeight: FontWeight.w500),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  return base.copyWith(
    appBarTheme: base.appBarTheme.copyWith(
      backgroundColor: pokedexRed,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(.3),
      titleTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.5,
      ),
    ),
    cardTheme: base.cardTheme.copyWith(
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.all(0),
      surfaceTintColor: Colors.transparent,
    ),
    chipTheme: base.chipTheme.copyWith(
      shape: StadiumBorder(
        side: BorderSide(color: accentBlue.withOpacity(.3), width: 1.2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: pokedexRed,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
  );
}