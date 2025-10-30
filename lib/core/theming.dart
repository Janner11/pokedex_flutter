import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tema global Material 3 con guiños a Pokédex:
/// - Primario rojo (#E3350D) como la tapa de la Pokédex
/// - Secundario azul (#6493EB) para énfasis sutil
/// - Superficies con esquinas redondeadas y elevación suave
ThemeData appTheme() {
  const pokedexRed = Color(0xFFE3350D);
  const accentBlue = Color(0xFF6493EB);

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: pokedexRed,
      primary: pokedexRed,
      secondary: accentBlue,
      brightness: Brightness.light,
    ),
    textTheme: GoogleFonts.robotoTextTheme(),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  return base.copyWith(
    appBarTheme: base.appBarTheme.copyWith(
      backgroundColor: pokedexRed,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 3,
      shadowColor: Colors.black.withOpacity(.25),
    ),
    cardTheme: base.cardTheme.copyWith(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: const EdgeInsets.all(0),
    ),
    chipTheme: base.chipTheme.copyWith(
      shape: StadiumBorder(side: BorderSide(color: accentBlue.withOpacity(.25))),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    ),
  );
}
