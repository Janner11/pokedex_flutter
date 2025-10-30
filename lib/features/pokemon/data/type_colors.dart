import 'package:flutter/material.dart';

/// Mapa de colores por tipo mejorados para mejor contraste
const Map<String, int> _typeHex = {
  'normal': 0xFFAAA67F,
  'fire': 0xFFFF7E2A,
  'water': 0xFF5A9DFF,
  'electric': 0xFFFFD43A,
  'grass': 0xFF6BC45A,
  'ice': 0xFF7BD3DE,
  'fighting': 0xFFD8415C,
  'poison': 0xFFB563CE,
  'ground': 0xFFE3B668,
  'flying': 0xFF9F8BFF,
  'psychic': 0xFFFF6B9D,
  'bug': 0xFFA8C234,
  'rock': 0xFFC8B16B,
  'ghost': 0xFF7B62A3,
  'dragon': 0xFF7B5CFF,
  'dark': 0xFF8C6452,
  'steel': 0xFFB7B8D0,
  'fairy': 0xFFEE99AC,
};

Color typeColor(String type, Color fallback) {
  final hex = _typeHex[type.toLowerCase()];
  return hex != null ? Color(hex) : fallback;
}

/// Función adicional para obtener gradientes por tipo
Gradient typeGradient(String type, BuildContext context) {
  final base = typeColor(type, Theme.of(context).colorScheme.secondary);
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      base.withOpacity(.25),
      base.withOpacity(.1),
      base.withOpacity(.05),
    ],
    stops: const [0.0, 0.6, 1.0],
  );
}