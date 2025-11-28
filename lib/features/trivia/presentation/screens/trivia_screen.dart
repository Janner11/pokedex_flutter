import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../pokemon/domain/models/pokemon.dart';
import '../../data/achievements_repository.dart';
import '../../data/ranking_repository.dart';
import '../../domain/models/achievement.dart';

const getTriviaPokemon = r"""
  query GetTriviaPokemon($limit: Int!) {
    pokemon_v2_pokemon(limit: $limit, where: {id: {_lte: 151}}) {
      id
      name
      pokemon_v2_pokemonsprites {
        sprites
      }
    }
  }
""";

class TriviaScreen extends StatefulWidget {
  const TriviaScreen({super.key});

  @override
  State<TriviaScreen> createState() => _TriviaScreenState();
}

class _TriviaScreenState extends State<TriviaScreen> {
  final _rankingRepo = RankingRepository();
  final _achievementsRepo = AchievementsRepository();
  
  int _score = 0;
  int _streak = 0;
  int _timeLeft = 10;
  Timer? _timer;

  List<Pokemon> _allPokemon = [];
  Pokemon? _correctPokemon;
  List<Pokemon> _options = [];
  bool _gameEnded = false;
  bool _isRevealed = false; // New state to control image visibility
  Set<String> _unlockedAchievements = {};

  @override
  void initState() {
    super.initState();
    _loadUnlockedAchievements();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadUnlockedAchievements() async {
    _unlockedAchievements = await _achievementsRepo.getUnlockedAchievements();
  }

  void _startNewRound() {
    if (_allPokemon.isEmpty) return;

    final random = Random();
    _allPokemon.shuffle(random);

    final selectedPokemon = _allPokemon.take(4).toList();
    
    setState(() {
      _correctPokemon = selectedPokemon[0];
      _options = selectedPokemon..shuffle(random);
      _timeLeft = 10;
      _gameEnded = false;
      _isRevealed = false; // Reset revealed state for new round
    });

    _startTimer();
  }
  
  void _resetGame() {
    setState(() {
      _score = 0;
      _streak = 0;
    });
    _startNewRound();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _handleAnswer(null); // Time's up counts as wrong answer
      }
    });
  }

  void _handleAnswer(Pokemon? selectedOption) {
    _timer?.cancel();
    bool isCorrect = selectedOption?.id == _correctPokemon?.id;

    if (isCorrect) {
      setState(() {
        _score += 10;
        _streak++;
        _isRevealed = true; // Reveal the pokemon
      });
      _checkAchievements();
      
      // Wait for 1.5 seconds then start next round
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          _startNewRound();
        }
      });
    } else {
      _endGame();
    }
  }

  void _checkAchievements() {
    // First Guess
    _unlockAchievement(allAchievements[0]); // 'first_guess'

    // Streak 5
    if (_streak >= 5) {
      _unlockAchievement(allAchievements[1]); // 'streak_5'
    }

    // Score 100
    if (_score >= 100) {
      _unlockAchievement(allAchievements[2]); // 'score_100'
    }
    
    // Score 500
    if (_score >= 500) {
      _unlockAchievement(allAchievements[3]); // 'score_500'
    }
  }

  void _unlockAchievement(Achievement achievement) {
    if (!_unlockedAchievements.contains(achievement.id)) {
      _unlockedAchievements.add(achievement.id);
      _achievementsRepo.unlockAchievement(achievement.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Logro desbloqueado: ${achievement.name}!'),
          backgroundColor: Colors.amber[800],
        ),
      );
    }
  }

  void _endGame() {
    _timer?.cancel();
    setState(() {
      _gameEnded = true;
      _streak = 0; // Reset streak
    });
    if (_score > 0) {
      _showSaveScoreDialog();
    }
  }

  Future<void> _showSaveScoreDialog() async {
    final nameController = TextEditingController();
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¡Fin del juego!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Tu puntuación final es: $_score'),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Tu nombre',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Guardar y ver ranking'),
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  _rankingRepo.saveScore(nameController.text, _score);
                  Navigator.of(context).pop();
                  context.go('/trivia/ranking');
                }
              },
            ),
            TextButton(
              child: const Text('Jugar de nuevo'),
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildGameUI() {
    if (_correctPokemon == null) {
      return const Center(child: Text("Cargando trivia..."));
    }

    // The image widget, which is now conditional
    Widget pokemonImage = Image.network(
      _correctPokemon!.imageUrl,
      height: 200,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, size: 100),
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Puntuación: $_score', style: const TextStyle(fontSize: 18)),
              Text('Racha: $_streak', style: const TextStyle(fontSize: 18)),
              Text('Tiempo: $_timeLeft', style: const TextStyle(fontSize: 18)),
            ],
          ),
          const Spacer(),
          Center(
            // Apply the shadow filter only if the image is not revealed
            child: _isRevealed
                ? pokemonImage
                : ColorFiltered(
                    colorFilter: const ColorFilter.mode(
                      Colors.black,
                      BlendMode.srcIn,
                    ),
                    child: pokemonImage,
                  ),
          ),
          const Spacer(),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 3,
            children: _options.map((pokemon) {
              return ElevatedButton(
                // Disable buttons while the correct answer is being revealed
                onPressed: _gameEnded || _isRevealed ? null : () => _handleAnswer(pokemon),
                child: Text(pokemon.name[0].toUpperCase() + pokemon.name.substring(1)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('¿Quién es este Pokémon?'),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () => context.push('/trivia/ranking'),
          ),
          IconButton(
            icon: const Icon(Icons.emoji_events),
            onPressed: () => context.push('/trivia/achievements'),
          ),
        ],
      ),
      body: Query(
        options: QueryOptions(
          document: gql(getTriviaPokemon),
          variables: const {'limit': 151},
        ),
        builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (result.hasException) {
            return Center(child: Text("Error al cargar los Pokémon: ${result.exception.toString()}"));
          }

          if (_allPokemon.isEmpty) {
            final pokemonListRaw = result.data?['pokemon_v2_pokemon'] as List? ?? [];
            _allPokemon = pokemonListRaw.map((p) => Pokemon.fromMap(p)).toList();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _startNewRound();
            });
          }

          return _buildGameUI();
        },
      ),
    );
  }
}
