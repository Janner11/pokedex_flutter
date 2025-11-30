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
          child: const Icon(
            Icons.location_on,
            color: Colors.red,
            size: 40.0,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Ubicación de $pokemonName'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: regionLatLng ?? const LatLng(-45, 135),
                initialZoom: 3.0,
                cameraConstraint: CameraConstraint.contain(
                  bounds: LatLngBounds(
                    const LatLng(-90, 0),
                    const LatLng(0, 180),
                  ),
                ),
              ),
              children: [
                // Cargar el mapa Pokémon como una sola imagen
                OverlayImageLayer(
                  overlayImages: [
                    OverlayImage(
                      bounds: LatLngBounds(
                        const LatLng(-90, 0),
                        const LatLng(0, 180),
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
          ),
          // --- INFO PANEL ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Ubicación Principal",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  regionName,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                if (regionLatLng != null)
                  Chip(
                    avatar: const Icon(Icons.explore, size: 16, color: Colors.white),
                    label: Text(
                      "Lat: ${regionLatLng.latitude.toStringAsFixed(1)}, Lng: ${regionLatLng.longitude.toStringAsFixed(1)}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  )
                else
                  const Text(
                    "Ubicación desconocida en este mapa",
                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
