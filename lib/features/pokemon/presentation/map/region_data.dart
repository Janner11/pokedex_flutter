import 'package:latlong2/latlong.dart';

/// Un mapa que asocia cada región de Pokémon con una coordenada LatLng única.
final Map<String, LatLng> regionCoordinates = {
  'Kanto': LatLng(-35.5, 140.2),
  'Johto': LatLng(-45.0, 130.0),
  'Hoenn': LatLng(-60.0, 125.0),
  'Sinnoh': LatLng(-25.0, 155.0),
  'Unova': LatLng(-30.0, 175.0),
  'Kalos': LatLng(-50.0, 110.0),
  'Alola': LatLng(-70.0, 160.0),
  'Galar': LatLng(-20.0, 115.0), // Coordenada de ejemplo para Galar
  // Puedes agregar más regiones y sus coordenadas aquí
};

/// Devuelve el nombre de la región correspondiente al ID de un Pokémon.
String getRegionFromId(int id) {
  if (id >= 1 && id <= 151) {
    return 'Kanto';
  } else if (id >= 152 && id <= 251) {
    return 'Johto';
  } else if (id >= 252 && id <= 386) {
    return 'Hoenn';
  } else if (id >= 387 && id <= 493) {
    return 'Sinnoh';
  } else if (id >= 494 && id <= 649) {
    return 'Unova';
  } else if (id >= 650 && id <= 721) {
    return 'Kalos';
  } else if (id >= 722 && id <= 809) {
    return 'Alola';
  } else if (id >= 810 && id <= 905) {
    return 'Galar';
  }
  // Por defecto, si el ID está fuera de los rangos conocidos
  return 'Unknown';
}
