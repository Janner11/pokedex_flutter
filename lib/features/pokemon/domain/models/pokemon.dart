import 'dart:convert';

// A type to represent a single pokemon in an evolution chain.
typedef Evolution = ({
  int id,
  String name,
  String imageUrl,
});

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

  const Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.stats,
    required this.abilities,
    required this.evolutionChain,
    required this.moves,
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

    final List<Evolution> evolutionChain = [];
    final speciesData = map['pokemon_v2_pokemonspecy'];
    if (speciesData != null) {
      final chainData = speciesData['pokemon_v2_evolutionchain']['pokemon_v2_pokemonspecies'] as List;
      for (final species in chainData) {
        final spritesList = species['pokemon_v2_pokemons']?.first?['pokemon_v2_pokemonsprites'] as List?;
        final evoSpritesRaw = spritesList?.first?['sprites'];
        if (evoSpritesRaw != null) {
          final evoSpritesMap = _parseSprites(evoSpritesRaw);
          final evoImageUrl = evoSpritesMap['other']?['official-artwork']?['front_default'] ?? evoSpritesMap['front_default'] ?? '';
          evolutionChain.add((
            id: species['id'],
            name: species['name'],
            imageUrl: evoImageUrl,
          ));
        }
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
    );
  }
}
