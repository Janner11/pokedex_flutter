import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const pokedexRed = Color(0xFFE3350D);
const accentBlue = Color(0xFF6493EB);

/// Tema Claro
ThemeData appThemeLight() {
  const backgroundWhite = Color(0xFFF8F9FA);

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: pokedexRed,
      primary: pokedexRed,
      secondary: accentBlue,
      brightness: Brightness.light,
      background: backgroundWhite,
      surface: Colors.white,
    ),
    textTheme: GoogleFonts.robotoFlexTextTheme(),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  return _buildTheme(base, isDark: false);
}

/// Tema Oscuro
ThemeData appThemeDark() {
  const backgroundDark = Color(0xFF121212);
  const surfaceDark = Color(0xFF1E1E1E);

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: pokedexRed,
      primary: pokedexRed,
      secondary: accentBlue,
      brightness: Brightness.dark,
      background: backgroundDark,
      surface: surfaceDark,
    ),
    textTheme: GoogleFonts.robotoFlexTextTheme(ThemeData.dark().textTheme),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  return _buildTheme(base, isDark: true);
}

/// Función auxiliar para aplicar estilos comunes
ThemeData _buildTheme(ThemeData base, {required bool isDark}) {
  return base.copyWith(
    appBarTheme: base.appBarTheme.copyWith(
      backgroundColor: pokedexRed,
      // En modo oscuro, texto negro. En claro, blanco.
      foregroundColor: isDark ? Colors.black : Colors.white,
      centerTitle: true,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(.3),
      titleTextStyle: TextStyle(
        color: isDark ? Colors.black : Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.5,
      ),
      iconTheme: IconThemeData(
        color: isDark ? Colors.black : Colors.white,
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
