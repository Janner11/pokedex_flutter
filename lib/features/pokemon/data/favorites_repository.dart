import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../domain/models/pokemon.dart';

/// A repository that handles the logic for storing and retrieving favorite Pokémon.
class FavoritesRepository {
  static const _boxName = 'favorites';
  static const _detailsBoxName = 'favorite_details';

  // Gets the Hive box for favorite IDs.
  Box<int> get a_box => Hive.box<int>(_boxName);
  
  // Gets the Hive box for favorite details.
  Box<Map> get details_box => Hive.box<Map>(_detailsBoxName);

  /// Checks if a Pokémon with the given [id] is a favorite.
  bool isFavorite(int id) {
    return a_box.containsKey(id);
  }

  /// Adds a Pokémon to the favorites list.
  Future<void> add(Pokemon pokemon) async {
    // Save ID for quick lookup
    await a_box.put(pokemon.id, pokemon.id);

    // --- IMAGE PERSISTENCE LOGIC ---
    String? base64Image = pokemon.imageBase64;

    // If the pokemon object doesn't have the base64 image yet, try to download it
    if (base64Image == null && pokemon.imageUrl.isNotEmpty) {
      try {
        final httpClient = HttpClient();
        final request = await httpClient.getUrl(Uri.parse(pokemon.imageUrl));
        final response = await request.close();
        if (response.statusCode == 200) {
          final bytes = await consolidateHttpClientResponseBytes(response);
          base64Image = base64Encode(bytes);
        }
      } catch (e) {
        // Ignore download errors, we'll just save without the image
        debugPrint('Error downloading image for favorite: $e');
      }
    }
    // -------------------------------
    
    // Save minimal details needed for the list, INCLUDING the base64 image
    final minimalDetails = {
      'id': pokemon.id,
      'name': pokemon.name,
      'pokemon_v2_pokemontypes': pokemon.types.map((t) => {
        'pokemon_v2_type': {'name': t}
      }).toList(),
      'pokemon_v2_pokemonsprites': [
        {
          'sprites': {
            'front_default': pokemon.imageUrl,
            'other': {
              'official-artwork': {'front_default': pokemon.imageUrl}
            }
          }
        }
      ],
      'imageBase64': base64Image, // Save the base64 string
    };
    await details_box.put(pokemon.id, minimalDetails);
  }

  /// Removes a Pokémon from the favorites list.
  Future<void> remove(int id) async {
    await a_box.delete(id);
    await details_box.delete(id);
  }

  /// Toggles the favorite status of a Pokémon.
  Future<void> toggle(Pokemon pokemon) async {
    if (isFavorite(pokemon.id)) {
      await remove(pokemon.id);
    } else {
      await add(pokemon);
    }
  }
}
