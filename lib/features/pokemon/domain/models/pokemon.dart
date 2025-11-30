import 'dart:convert';

// A type to represent a single pokemon in an evolution chain.
typedef Evolution = ({
  int id,
  String name,
  String imageUrl,
  String trigger,
});

// A type to represent a single move.
typedef Move = ({
  String name,
  String type,
  int? power,
  int? pp,
  int level,
  String learnMethod,
  String versionGroup, // The game where the move is learned
});

// A type for Pokemon Variants
typedef Variant = ({
  int id,
  String name,
  bool isDefault,
});

// A type for Abilities with more info
typedef Ability = ({
  String name,
  bool isHidden,
  String description,
});

class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final String shinyImageUrl;
  final List<String> types;
  final Map<String, int> stats;
  final List<Ability> abilities;
  final List<EvolutionNode> evolutionChain;
  final List<Move> moves;
  final int generationId;
  final int height;
  final int weight;
  final String description;
  final int genderRate;
  final List<String> eggGroups;
  final String? imageBase64;
  final List<Variant> variants;

  const Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.shinyImageUrl,
    required this.types,
    required this.stats,
    required this.abilities,
    required this.evolutionChain,
    required this.moves,
    required this.generationId,
    required this.height,
    required this.weight,
    required this.description,
    required this.genderRate,
    required this.eggGroups,
    this.imageBase64,
    required this.variants,
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
    // FIX: Relaxed type check to handle Hive's Map<dynamic, dynamic>
    Map<String, dynamic> _parseSprites(dynamic spritesField) {
      if (spritesField is String) {
        try {
          return jsonDecode(spritesField);
        } catch (e) {
          return {};
        }
      }
      if (spritesField is Map) {
        return Map<String, dynamic>.from(spritesField);
      }
      return {};
    }

    final int id = map['id'];
    final String name = map['name'];
    final int height = map['height'] ?? 0;
    final int weight = map['weight'] ?? 0;
    
    final speciesData = map['pokemon_v2_pokemonspecy'];
    final int generationId = speciesData?['generation_id'] ?? 1;
    final int genderRate = speciesData?['gender_rate'] ?? -1;

    String description = '';
    if (speciesData != null && speciesData['pokemon_v2_pokemonspeciesflavortexts'] != null) {
      final flavorTexts = speciesData['pokemon_v2_pokemonspeciesflavortexts'] as List;
      var textEntry = flavorTexts.firstWhere(
          (e) => e['language_id'] == 7, 
          orElse: () => flavorTexts.firstWhere((e) => e['language_id'] == 9, orElse: () => null)
      );
      
      if (textEntry != null) {
        description = (textEntry['flavor_text'] as String)
            .replaceAll('\n', ' ')
            .replaceAll('\f', ' ')
            .replaceAll('  ', ' ');
      }
    }

    final List<String> eggGroups = [];
    if (speciesData != null && speciesData['pokemon_v2_pokemonegggroups'] != null) {
      final groupsData = speciesData['pokemon_v2_pokemonegggroups'] as List;
      eggGroups.addAll(groupsData.map((e) => e['pokemon_v2_egggroup']['name'] as String));
    }

    final List<Variant> variants = [];
    if (speciesData != null && speciesData['pokemon_v2_pokemons'] != null) {
      for (var v in speciesData['pokemon_v2_pokemons'] as List) {
        variants.add((
          id: v['id'],
          name: v['name'],
          isDefault: v['is_default'] ?? false,
        ));
      }
    }

    final List<String> types = (map['pokemon_v2_pokemontypes'] as List)
        .map((t) => t['pokemon_v2_type']['name'] as String)
        .toList();

    final spritesMap = _parseSprites(map['pokemon_v2_pokemonsprites'][0]['sprites']);
    final imageUrl = spritesMap['other']?['official-artwork']?['front_default'] ?? spritesMap['front_default'] ?? '';
    final shinyImageUrl = spritesMap['front_shiny'] ?? '';

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

    final List<Ability> abilities = [];
    if (map.containsKey('pokemon_v2_pokemonabilities')) {
      for (var a in map['pokemon_v2_pokemonabilities'] as List) {
        String abilityDesc = '';
        final flavorList = a['pokemon_v2_ability']['pokemon_v2_abilityflavortexts'] as List?;
        if (flavorList != null && flavorList.isNotEmpty) {
           abilityDesc = (flavorList.first['flavor_text'] as String)
              .replaceAll('\n', ' ');
        }

        abilities.add((
          name: a['pokemon_v2_ability']['name'] as String,
          isHidden: a['is_hidden'] as bool,
          description: abilityDesc,
        ));
      }
    }

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

            if (trigger == 'level-up') {
              if (detail['min_happiness'] != null) {
                if (detail['time_of_day'] == 'day') {
                  triggerText = 'High Friendship (day)';
                } else if (detail['time_of_day'] == 'night') {
                  triggerText = 'High Friendship (night)';
                } else {
                  triggerText = 'High Friendship';
                }
              } else if (detail['known_move_type_id'] == 18) { 
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
    if (speciesData != null) {
      final evolutionChainData = speciesData['pokemon_v2_evolutionchain'];
      if (evolutionChainData != null) {
        final chainData = evolutionChainData['pokemon_v2_pokemonspecies'] as List?;
        if (chainData != null && chainData.isNotEmpty) {
          evolutionChain = buildEvolutionTree(chainData);
        } else {
          evolutionChain = [];
        }
      } else {
        evolutionChain = [];
      }
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

    final String? imageBase64 = map['imageBase64'];

    return Pokemon(
      id: id,
      name: name,
      imageUrl: imageUrl,
      shinyImageUrl: shinyImageUrl,
      types: types,
      stats: stats,
      abilities: abilities,
      evolutionChain: evolutionChain,
      moves: moves,
      generationId: generationId,
      height: height,
      weight: weight,
      description: description,
      genderRate: genderRate,
      eggGroups: eggGroups,
      imageBase64: imageBase64,
      variants: variants,
    );
  }
}

// Represents a node in an evolution tree.
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
