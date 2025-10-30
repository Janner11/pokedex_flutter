import 'package:flutter/material.dart';

/// Mapa de colores por tipo para acentos y fondos sutiles
const Map<String, int> _typeHex = {
  'normal': 0xFFAAA67F,
  'fire': 0xFFF57D31,
  'water': 0xFF6493EB,
  'electric': 0xFFF9CF30,
  'grass': 0xFF74CB48,
  'ice': 0xFF9AD6DF,
  'fighting': 0xFFC12239,
  'poison': 0xFFA43E9E,
  'ground': 0xFFDEC16B,
  'flying': 0xFFA891EC,
  'psychic': 0xFFFB5584,
  'bug': 0xFFA7B723,
  'rock': 0xFFB69E31,
  'ghost': 0xFF70559B,
  'dragon': 0xFF7037FF,
  'dark': 0xFF75574C,
  'steel': 0xFFB7B9D0,
  'fairy': 0xFFE69EAC,
};

Color typeColor(String type, Color fallback) {
  final hex = _typeHex[type.toLowerCase()];
  return hex != null ? Color(hex) : fallback;
}
