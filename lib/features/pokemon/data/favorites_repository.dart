import 'package:hive_flutter/hive_flutter.dart';

/// A repository that handles the logic for storing and retrieving favorite Pokémon.
class FavoritesRepository {
  static const _boxName = 'favorites';

  // Gets the Hive box for favorites.
  Box<int> get a_box => Hive.box<int>(_boxName);

  /// Checks if a Pokémon with the given [id] is a favorite.
  bool isFavorite(int id) {
    return a_box.values.contains(id);
  }

  /// Adds a Pokémon with the given [id] to the favorites list.
  Future<void> add(int id) async {
    // Use id as the key for quick lookups and deletions.
    await a_box.put(id, id);
  }

  /// Removes a Pokémon with the given [id] from the favorites list.
  Future<void> remove(int id) async {
    await a_box.delete(id);
  }

  /// Toggles the favorite status of a Pokémon.
  Future<void> toggle(int id) async {
    if (isFavorite(id)) {
      await remove(id);
    } else {
      await add(id);
    }
  }
}
