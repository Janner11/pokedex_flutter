// lib/features/pokemon/data/mock.dart
class PokemonBasicMock {
  final int id;
  final String name;
  final String image;
  final List<String> types;
  PokemonBasicMock({required this.id, required this.name, required this.image, required this.types});
}

class PokemonDetailMock {
  final int id;
  final String name;
  final String image;
  final List<String> types;
  final Map<String, int> stats;       // e.g., {hp: 45, attack: 49, ...}
  final List<String> abilities;       // e.g., ["overgrow", "chlorophyll"]
  final List<String> moves;           // e.g., ["tackle", "vine-whip", ...]
  final List<Map<String, dynamic>> evolutions; // [{id:1,name:"bulbasaur"},...]
  PokemonDetailMock({
    required this.id,
    required this.name,
    required this.image,
    required this.types,
    required this.stats,
    required this.abilities,
    required this.moves,
    required this.evolutions,
  });
}

// Sprites oficiales (PokeAPI official-artwork)
const _img = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork";

final mockList = <PokemonBasicMock>[
  PokemonBasicMock(id: 1, name: "bulbasaur", image: "$_img/1.png", types: ["grass", "poison"]),
  PokemonBasicMock(id: 4, name: "charmander", image: "$_img/4.png", types: ["fire"]),
  PokemonBasicMock(id: 7, name: "squirtle", image: "$_img/7.png", types: ["water"]),
  PokemonBasicMock(id: 25, name: "pikachu", image: "$_img/25.png", types: ["electric"]),
  PokemonBasicMock(id: 133, name: "eevee", image: "$_img/133.png", types: ["normal"]),
  PokemonBasicMock(id: 39, name: "jigglypuff", image: "$_img/39.png", types: ["normal", "fairy"]),
];

final mockDetails = <int, PokemonDetailMock>{
  1: PokemonDetailMock(
    id: 1,
    name: "bulbasaur",
    image: "$_img/1.png",
    types: ["grass", "poison"],
    stats: {"hp": 45, "attack": 49, "defense": 49, "sp_atk": 65, "sp_def": 65, "speed": 45},
    abilities: ["overgrow", "chlorophyll"],
    moves: ["tackle", "vine-whip", "razor-leaf", "sleep-powder", "leech-seed", "growl", "poison-powder", "solar-beam"],
    evolutions: [
      {"id": 1, "name": "bulbasaur"},
      {"id": 2, "name": "ivysaur"},
      {"id": 3, "name": "venusaur"},
    ],
  ),
  4: PokemonDetailMock(
    id: 4,
    name: "charmander",
    image: "$_img/4.png",
    types: ["fire"],
    stats: {"hp": 39, "attack": 52, "defense": 43, "sp_atk": 60, "sp_def": 50, "speed": 65},
    abilities: ["blaze", "solar-power"],
    moves: ["scratch", "ember", "smokescreen", "dragon-breath", "fire-fang", "flamethrower", "slash"],
    evolutions: [
      {"id": 4, "name": "charmander"},
      {"id": 5, "name": "charmeleon"},
      {"id": 6, "name": "charizard"},
    ],
  ),
  7: PokemonDetailMock(
    id: 7,
    name: "squirtle",
    image: "$_img/7.png",
    types: ["water"],
    stats: {"hp": 44, "attack": 48, "defense": 65, "sp_atk": 50, "sp_def": 64, "speed": 43},
    abilities: ["torrent", "rain-dish"],
    moves: ["tackle", "water-gun", "withdraw", "bite", "rapid-spin", "aqua-tail", "hydro-pump"],
    evolutions: [
      {"id": 7, "name": "squirtle"},
      {"id": 8, "name": "wartortle"},
      {"id": 9, "name": "blastoise"},
    ],
  ),
  25: PokemonDetailMock(
    id: 25,
    name: "pikachu",
    image: "$_img/25.png",
    types: ["electric"],
    stats: {"hp": 35, "attack": 55, "defense": 40, "sp_atk": 50, "sp_def": 50, "speed": 90},
    abilities: ["static", "lightning-rod"],
    moves: ["thunder-shock", "quick-attack", "electro-ball", "spark", "slam", "thunderbolt", "iron-tail", "volt-tackle"],
    evolutions: [
      {"id": 172, "name": "pichu"},
      {"id": 25, "name": "pikachu"},
      {"id": 26, "name": "raichu"},
    ],
  ),
  133: PokemonDetailMock(
    id: 133,
    name: "eevee",
    image: "$_img/133.png",
    types: ["normal"],
    stats: {"hp": 55, "attack": 55, "defense": 50, "sp_atk": 45, "sp_def": 65, "speed": 55},
    abilities: ["run-away", "adaptability", "anticipation"],
    moves: ["tackle", "quick-attack", "bite", "swift", "copycat", "take-down", "double-edge"],
    evolutions: [
      {"id": 134, "name": "vaporeon"},
      {"id": 135, "name": "jolteon"},
      {"id": 136, "name": "flareon"},
      {"id": 196, "name": "espeon"},
      {"id": 197, "name": "umbreon"},
      {"id": 470, "name": "leafeon"},
      {"id": 471, "name": "glaceon"},
      {"id": 700, "name": "sylveon"},
    ],
  ),
  39: PokemonDetailMock(
    id: 39,
    name: "jigglypuff",
    image: "$_img/39.png",
    types: ["normal", "fairy"],
    stats: {"hp": 115, "attack": 45, "defense": 20, "sp_atk": 45, "sp_def": 25, "speed": 20},
    abilities: ["cute-charm", "competitive", "friend-guard"],
    moves: ["sing", "pound", "disable", "rollout", "double-slap", "body-slam", "hyper-voice"],
    evolutions: [
      {"id": 174, "name": "igglybuff"},
      {"id": 39, "name": "jigglypuff"},
      {"id": 40, "name": "wigglytuff"},
    ],
  ),
};
