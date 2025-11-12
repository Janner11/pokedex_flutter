import 'dart:convert';

// Represents a node in an evolution tree.
// It can have its own list of subsequent evolutions (branches).
class EvolutionNode {
  final int id;
  final String name;
  final String imageUrl;
  final String trigger;
  final List<EvolutionNode> evolutions;

  const EvolutionNode({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.trigger,
    this.evolutions = const [],
  });
}

typedef Move = ({
  String name,
  String type,
  int? power,
  int? pp,
  int level,
  String learnMethod,
  String versionGroup,
});

class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;
  final Map<String, int> stats;
  final List<String> abilities;
  final List<EvolutionNode> evolutionChain;
  final List<Move> moves;
  final int generationId;

  const Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.stats,
    required this.abilities,
    required this.evolutionChain,
    required this.moves,
    required this.generationId,
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
    final int generationId = map['pokemon_v2_pokemonspecy']?['generation_id'] ?? 1;

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

    // --- HIERARCHICAL EVOLUTION CHAIN PARSING (IMPROVED) ---
    List<EvolutionNode> buildEvolutionTree(List<dynamic> speciesList) {
      final nodeMap = <int, EvolutionNode>{};
      final triggerMap = <int, String>{};

      for (final species in speciesList) {
        final int speciesId = species['id'];

        final spritesList = species['pokemon_v2_pokemons']?.first?['pokemon_v2_pokemonsprites'] as List?;
        final evoSpritesRaw = spritesList?.first?['sprites'];
        final evoSpritesMap = evoSpritesRaw != null ? _parseSprites(evoSpritesRaw) : {};
        final evoImageUrl = evoSpritesMap['other']?['official-artwork']?['front_default'] ?? evoSpritesMap['front_default'] ?? '';
        
        final evoDetails = species['pokemon_v2_pokemonevolutions'] as List;
        if (evoDetails.isNotEmpty) {
            final detail = evoDetails.first;
            final trigger = detail['pokemon_v2_evolutiontrigger']['name'];
            String triggerText = '';

            // --- ENHANCED TRIGGER LOGIC ---
            if (trigger == 'level-up') {
              if (detail['min_happiness'] != null) {
                if (detail['time_of_day'] == 'day') {
                  triggerText = 'High Friendship (day)';
                } else if (detail['time_of_day'] == 'night') {
                  triggerText = 'High Friendship (night)';
                } else {
                  triggerText = 'High Friendship';
                }
              } else if (detail['known_move_type_id'] == 18) { // 18 is the ID for Fairy type
                triggerText = 'Knows Fairy-type move';
              } else if (detail['pokemon_v2_location'] != null) {
                triggerText = 'Near special location';
              } else {
                triggerText = 'Nivel ${detail['min_level']}';
              }
            } else if (trigger == 'trade') {
              triggerText = 'Intercambio';
            } else if (trigger == 'use-item') {
              final itemName = detail['pokemon_v2_item']?['name']?.replaceAll('-', ' ') ?? '';
              final capitalizedItemName = itemName.split(' ').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
              triggerText = 'Usar $capitalizedItemName';
            }
            triggerMap[speciesId] = triggerText;
        }

        nodeMap[speciesId] = EvolutionNode(
          id: speciesId,
          name: species['name'],
          imageUrl: evoImageUrl,
          trigger: triggerMap[speciesId] ?? '',
          evolutions: [],
        );
      }

      final rootNodes = <EvolutionNode>[];
      for (final species in speciesList) {
        final int speciesId = species['id'];
        final parentId = species['evolves_from_species_id'];
        final currentNode = nodeMap[speciesId]!;

        if (parentId != null && nodeMap.containsKey(parentId)) {
          nodeMap[parentId]!.evolutions.add(currentNode);
        } else {
          rootNodes.add(currentNode);
        }
      }
      return rootNodes;
    }

    final List<EvolutionNode> evolutionChain;
    final speciesData = map['pokemon_v2_pokemonspecy'];
    final evolutionChainData = speciesData?['pokemon_v2_evolutionchain'];
    final chainSpeciesList = evolutionChainData?['pokemon_v2_pokemonspecies'] as List?;
    
    if (chainSpeciesList != null && chainSpeciesList.isNotEmpty) {
      evolutionChain = buildEvolutionTree(chainSpeciesList);
    } else {
      evolutionChain = [];
    }

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
          versionGroup: moveData['pokemon_v2_versiongroup']['name'],
        ));
      }
    }
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
