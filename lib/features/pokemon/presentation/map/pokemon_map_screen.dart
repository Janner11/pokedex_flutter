import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'region_data.dart'; // Importamos el nuevo archivo

class PokemonMapScreen extends StatelessWidget {
  static const String route = '/pokemon_map/:pokemonName/:pokemonId';

  final String pokemonName;
  final int pokemonId;

  const PokemonMapScreen({
    Key? key,
    required this.pokemonName,
    required this.pokemonId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. Determinar la región a partir del ID del Pokémon
    final String regionName = getRegionFromId(pokemonId);

    // 2. Buscar las coordenadas de esa región
    final LatLng? regionLatLng = regionCoordinates[regionName];

    // Preparamos el marcador para la región
    final List<Marker> markers = [];
    if (regionLatLng != null) {
      markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: regionLatLng,
          child: Tooltip(
            message: regionName,
            child: const Icon(
              Icons.location_on,
              color: Colors.red,
              size: 40.0,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Ubicación de $pokemonName'),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: regionLatLng ?? LatLng(-45, 135),
          initialZoom: 3.0,
          cameraConstraint: CameraConstraint.contain(
            bounds: LatLngBounds(
              LatLng(-90, 0),
              LatLng(0, 180),
            ),
          ),

          // 🔥 LO QUE AÑADÍ PARA CALIBRAR
          onTap: (tapPosition, point) {
            print("TAP → LAT: ${point.latitude}, LNG: ${point.longitude}");
          },
        ),

        children: [
          // Cargar el mapa Pokémon como una sola imagen
          OverlayImageLayer(
            overlayImages: [
              OverlayImage(
                bounds: LatLngBounds(
                  LatLng(-90, 0),
                  LatLng(0, 180),
                ),
                opacity: 1.0,
                imageProvider: const AssetImage("assets/images/world_map.png"),
              ),
            ],
          ),

          // Marcador único para la región del Pokémon
          MarkerLayer(markers: markers),
        ],
      ),
    );
  }
}
