import 'dart:convert';

class Evolution {
  final int id;
  final String name;
  final String imageUrl;
  final String evolutionDetails;
  final List<Evolution> evolutions;

  Evolution({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.evolutionDetails,
    this.evolutions = const [],
  });
}

// A type to represent a single move.
typedef Move = ({
  String name,
  String type,
  int? power,
  int? pp,
  int level,
  String learnMethod,
});

class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;
  final Map<String, int> stats;
  final List<String> abilities;
  final List<Evolution> evolutionChain;
  final List<Move> moves;
  final int? generationId;

  const Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.stats,
    required this.abilities,
    required this.evolutionChain,
    required this.moves,
    this.generationId,
  });

  static const Map<String, String> _statNameMapping = {
    'hp': 'HP',
    'attack': 'ATK',
    'defense': 'DEF',
    'special-attack': 'SPA',
    'special-defense': 'SPD',
    'speed': 'SPE',
  };

  factory Pokemon.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic> _parseSprites(dynamic spritesField) {
      if (spritesField is String) return jsonDecode(spritesField);
      if (spritesField is Map<String, dynamic>) return spritesField;
      return {};
    }

    final int id = map['id'];
    final String name = map['name'];

    final List<String> types = (map['pokemon_v2_pokemontypes'] as List)
        .map((t) => t['pokemon_v2_type']['name'] as String)
        .toList();

    final spritesMap = _parseSprites(map['pokemon_v2_pokemonsprites'][0]['sprites']);
    final imageUrl = spritesMap['other']?['official-artwork']?['front_default'] ?? spritesMap['front_default'] ?? '';

    final Map<String, int> stats = {};
    if (map.containsKey('pokemon_v2_pokemonstats')) {
      for (var e in map['pokemon_v2_pokemonstats']) {
        final apiStatName = e['pokemon_v2_stat']['name'] as String;
        final shortStatName = _statNameMapping[apiStatName];
        if (shortStatName != null) {
          stats[shortStatName] = e['base_stat'] as int;
        }
      }
    }

    final List<String> abilities = [];
    if (map.containsKey('pokemon_v2_pokemonabilities')) {
      abilities.addAll((map['pokemon_v2_pokemonabilities'] as List)
          .map((a) => a['pokemon_v2_ability']['name'] as String));
    }

    // --- EVOLUTION CHAIN PARSING ---
    final List<Evolution> evolutionChain = [];
    final speciesData = map['pokemon_v2_pokemonspecy'];
    int? generationId;
    if (speciesData != null) {
      generationId = speciesData['generation_id'];
      final chainData = speciesData['pokemon_v2_evolutionchain']?['pokemon_v2_pokemonspecies'] as List?;
      if (chainData != null) {
        final evolutionMap = <int, List<Map<String, dynamic>>>{};
        for (final species in chainData) {
          final fromId = species['evolves_from_species_id'];
          evolutionMap.putIfAbsent(fromId ?? 0, () => []).add(species);
        }

        List<Evolution> buildEvolutionTree(int? parentId) {
          final childrenData = evolutionMap[parentId ?? 0] ?? [];
          return childrenData.map((species) {
            final spritesList = species['pokemon_v2_pokemons']?.first?['pokemon_v2_pokemonsprites'] as List?;
            final evoSpritesRaw = spritesList?.first?['sprites'];
            final evoSpritesMap = _parseSprites(evoSpritesRaw!);
            final evoImageUrl = evoSpritesMap['other']?['official-artwork']?['front_default'] ?? evoSpritesMap['front_default'] ?? '';

            String evolutionDetails = '';
            final evolutionData = species['pokemon_v2_pokemonevolutions'] as List?;
            if (evolutionData != null && evolutionData.isNotEmpty) {
              final details = evolutionData.first;
              final trigger = details['pokemon_v2_evolutiontrigger']['name'];

              if (trigger == 'level-up') {
                if (details['min_level'] != null) {
                  evolutionDetails = 'Level ${details['min_level']}';
                } else if (details['min_happiness'] != null) {
                  evolutionDetails = 'High Friendship';
                  if (details['time_of_day'] != null && details['time_of_day'] != '') {
                    evolutionDetails += ' (${details['time_of_day']})';
                  }
                } else if (details['known_move_type_id'] != null) {
                  evolutionDetails = 'Knows a Fairy-type move';
                } else if (details['pokemon_v2_location'] != null) {
                  evolutionDetails = 'Level up near ${details['pokemon_v2_location']['name']}';
                } else {
                  evolutionDetails = 'Level up';
                }
              } else if (trigger == 'trade') {
                evolutionDetails = 'Trade';
              } else if (trigger == 'use-item') {
                evolutionDetails = 'Use ${details['pokemon_v2_item']['name']}';
              } else if (trigger == 'shed') {
                evolutionDetails = 'Shed';
              } else if (trigger == 'other') {
                evolutionDetails = 'Other';
              }
            }

            return Evolution(
              id: species['id'],
              name: species['name'],
              imageUrl: evoImageUrl,
              evolutionDetails: evolutionDetails,
              evolutions: buildEvolutionTree(species['id']),
            );
          }).toList();
        }

        evolutionChain.addAll(buildEvolutionTree(null));
      }
    }

    // --- MOVES PARSING ---
    final List<Move> moves = [];
    if (map.containsKey('pokemon_v2_pokemonmoves')) {
      for (final moveData in map['pokemon_v2_pokemonmoves'] as List) {
        moves.add((
          name: moveData['pokemon_v2_move']['name'],
          type: moveData['pokemon_v2_move']['pokemon_v2_type']?['name'] ?? 'normal',
          power: moveData['pokemon_v2_move']['power'],
          pp: moveData['pokemon_v2_move']['pp'],
          level: moveData['level'],
          learnMethod: moveData['pokemon_v2_movelearnmethod']['name'],
        ));
      }
    }
    // Sort moves by level by default
    moves.sort((a, b) => a.level.compareTo(b.level));

    return Pokemon(
      id: id,
      name: name,
      imageUrl: imageUrl,
      types: types,
      stats: stats,
      abilities: abilities,
      evolutionChain: evolutionChain,
      moves: moves,
      generationId: generationId,
    );
  }
}
