import 'package:latlong2/latlong.dart';

/// Coordenadas calibradas para el mapa Pokémon (regiones principales)
final Map<String, LatLng> regionCoordinates = {
  'Kanto': LatLng(-78.70505533067191, 118.9337342977524),
  'Johto': LatLng(-78.92374237966813, 98.76567900180818),
  'Hoenn': LatLng(-78.76159583189653, 74.3995374441147),
  'Sinnoh': LatLng(-57.68530000186189, 135.77080011421663),
  'Unova': LatLng(-71.33915102614615, 45.85002948599962),
  'Kalos': LatLng(-54.464028038886255, 39.044400053945445),
  'Alola': LatLng(-83.6811077139727, 70.44828716694775),
  'Galar': LatLng(-30.055695519957894, 18.08954256177323),
  'Paldea': LatLng(-71.37404753571955, 21.175250267394123),
};

/// Devuelve la región según el ID del Pokémon.
String getRegionFromId(int id) {
  if (id >= 1 && id <= 151) return 'Kanto';
  if (id >= 152 && id <= 251) return 'Johto';
  if (id >= 252 && id <= 386) return 'Hoenn';
  if (id >= 387 && id <= 493) return 'Sinnoh';
  if (id >= 494 && id <= 649) return 'Unova';
  if (id >= 650 && id <= 721) return 'Kalos';
  if (id >= 722 && id <= 809) return 'Alola';
  if (id >= 810 && id <= 905) return 'Galar';
  if (id >= 906 && id <= 1025) return 'Paldea';

  return 'Unknown';
}
