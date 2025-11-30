import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../pokemon/domain/models/pokemon.dart';
import '../../data/achievements_repository.dart';
import '../../data/ranking_repository.dart';
import '../../domain/models/achievement.dart';
import '../../../../l10n/app_localizations.dart';

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
  bool _isLoading = true;
  String? _errorMessage;
  bool _gameStarted = false;

  List<Pokemon> _allPokemon = [];
  Pokemon? _correctPokemon;
  List<Pokemon> _options = [];
  
  bool _gameEnded = false;
  bool _isRevealed = false;
  Set<String> _unlockedAchievements = {};

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initializeGame() async {
    await _loadUnlockedAchievements();
    await _loadPokemonData();
  }

  Future<void> _loadUnlockedAchievements() async {
    _unlockedAchievements = _achievementsRepo.getUnlockedAchievements();
  }

  Future<void> _loadPokemonData() async {
    try {
      final box = await Hive.openBox('pokemon_list_cache');
      final rawList = box.get('last_list');

      if (rawList != null && rawList is List && rawList.isNotEmpty) {
        final List<Pokemon> loaded = [];
        for (var item in rawList) {
          try {
            loaded.add(Pokemon.fromMap(Map<String, dynamic>.from(item)));
          } catch (e) {
            // Skip invalid items
          }
        }

        if (loaded.length >= 4) {
          if (mounted) {
            setState(() {
              _allPokemon = loaded;
              _isLoading = false;
            });
          }
        } else {
          _setError("No enough Pokémon. Please browse the Pokédex first.");
        }
      } else {
        _setError("No data found. Please visit the Pokédex tab to load initial data.");
      }
    } catch (e) {
      _setError("Error loading data: $e");
    }
  }

  void _setError(String msg) {
    if (mounted) {
      setState(() {
        _errorMessage = msg;
        _isLoading = false;
      });
    }
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _score = 0;
      _streak = 0;
      _gameEnded = false;
    });
    _startNewRound();
  }

  void _startNewRound() {
    if (_allPokemon.isEmpty) return;

    final random = Random();
    final validPokemon = _allPokemon.where((p) => p.imageUrl.isNotEmpty).toList();
    
    if (validPokemon.length < 4) {
       _setError("Not enough Pokémon with images.");
       return;
    }

    final Set<int> selectedIndices = {};
    while (selectedIndices.length < 4) {
      selectedIndices.add(random.nextInt(validPokemon.length));
    }
    
    final List<Pokemon> options = selectedIndices.map((i) => validPokemon[i]).toList();
    final correct = options[random.nextInt(4)];

    setState(() {
      _correctPokemon = correct;
      _options = options;
      _timeLeft = 10;
      _gameEnded = false;
      _isRevealed = false;
    });

    _startTimer();
  }
  
  void _resetGame() {
    setState(() {
      _score = 0;
      _streak = 0;
      _gameEnded = false;
    });
    _startNewRound();
  }

  void _quitGame() {
    _timer?.cancel();
    setState(() {
      _gameStarted = false;
      _score = 0;
      _streak = 0;
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _handleAnswer(null);
      }
    });
  }

  void _handleAnswer(Pokemon? selectedOption) {
    _timer?.cancel();
    if (_gameEnded) return;

    bool isCorrect = selectedOption?.id == _correctPokemon?.id;

    setState(() {
      _isRevealed = true;
    });

    if (isCorrect) {
      setState(() {
        _score += 10;
        _streak++;
      });
      _checkAchievements();
      
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted && _gameStarted) {
          _startNewRound();
        }
      });
    } else {
      setState(() {
        _gameEnded = true;
        _streak = 0;
      });
      Future.delayed(const Duration(milliseconds: 1000), () {
         if(mounted && _gameStarted) _showSaveScoreDialog();
      });
    }
  }

  void _checkAchievements() {
    _unlockAchievement(allAchievements[0]); 
    if (_streak >= 5) _unlockAchievement(allAchievements[1]);
    if (_score >= 100) _unlockAchievement(allAchievements[2]);
    if (_score >= 500) _unlockAchievement(allAchievements[3]);
  }

  void _unlockAchievement(Achievement achievement) {
    if (!_unlockedAchievements.contains(achievement.id)) {
      setState(() {
        _unlockedAchievements.add(achievement.id);
      });
      _achievementsRepo.unlockAchievement(achievement.id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('${AppLocalizations.of(context).achievementUnlocked} ${achievement.name}')),
            ],
          ),
          backgroundColor: Colors.amber[800],
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _showSaveScoreDialog() async {
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController();
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.gameOver),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('${l10n.finalScore}: $_score', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (_correctPokemon != null)
                   Text('Era: ${_correctPokemon!.name.toUpperCase()}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: l10n.yourName,
                    hintText: l10n.trainer,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.exit),
              onPressed: () {
                Navigator.of(context).pop();
                _quitGame();
              },
            ),
            TextButton(
              child: Text(l10n.playAgain),
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
            ),
            FilledButton(
              child: Text(l10n.saveRanking),
              onPressed: () {
                final name = nameController.text.isEmpty ? l10n.trainer : nameController.text;
                _rankingRepo.saveScore(name, _score);
                Navigator.of(context).pop();
                context.push('/trivia/ranking');
                _quitGame();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.triviaTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () => context.push('/trivia/ranking'),
            tooltip: l10n.ranking,
          ),
          IconButton(
            icon: const Icon(Icons.emoji_events),
            onPressed: () => context.push('/trivia/achievements'),
            tooltip: l10n.achievements,
          ),
        ],
      ),
      body: _isLoading 
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(l10n.loading)
            ]))
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                              _errorMessage = null;
                            });
                            _loadPokemonData();
                          },
                          child: Text(l10n.retry),
                        )
                      ],
                    ),
                  ),
                )
              : _gameStarted 
                  ? _buildGameUI(l10n) 
                  : _buildStartScreen(l10n),
    );
  }

  Widget _buildStartScreen(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.psychology_alt, size: 100, color: Colors.red),
            const SizedBox(height: 24),
            Text(
              l10n.triviaTitle,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.guessInstruction,
              style: TextStyle(fontSize: 16, color: theme.colorScheme.onBackground.withOpacity(0.7)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: Semantics(
                button: true,
                label: "Start the trivia game",
                child: FilledButton(
                  onPressed: _startGame,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: Text(
                    l10n.startGame,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameUI(AppLocalizations l10n) {
    final theme = Theme.of(context);
    
    if (_correctPokemon == null) return const SizedBox.shrink();

    Widget imageWidget;
    if (_correctPokemon!.imageBase64 != null) {
       imageWidget = Image.memory(
          base64Decode(_correctPokemon!.imageBase64!),
          height: 220,
          fit: BoxFit.contain,
       );
    } else {
       imageWidget = CachedNetworkImage(
          imageUrl: _correctPokemon!.imageUrl,
          height: 220,
          fit: BoxFit.contain,
          placeholder: (context, url) => const SizedBox(height: 220, width: 220),
          errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 100),
       );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Header Stats with Adaptive Colors
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3), // 🔹 Adaptable
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(l10n.score, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                    Text("$_score", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                  ],
                ),
                Column(
                  children: [
                    Text(l10n.streak, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                    Text("$_streak", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
                  ],
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: _timeLeft / 10,
                      backgroundColor: theme.colorScheme.surfaceVariant,
                      color: _timeLeft <= 3 ? Colors.red : Colors.green,
                    ),
                    Text("$_timeLeft", style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                  ],
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // The Silhouette
          SizedBox(
            height: 250,
            width: 250,
            child: _isRevealed
                ? imageWidget 
                : ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      theme.brightness == Brightness.dark ? Colors.white : Colors.black, // White silhouette in dark mode looks better? Or keep black? 
                      // Convention is black silhouette usually. Let's keep black for mystery feel, but ensure background allows seeing it.
                      BlendMode.srcIn,
                    ),
                    child: imageWidget,
                  ),
          ),
          
          const Spacer(),
          
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.8,
            children: _options.map((pokemon) {
              return Semantics(
                button: true,
                label: "Guess ${pokemon.name}",
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    backgroundColor: theme.colorScheme.surfaceVariant, // Adaptable button bg
                    foregroundColor: theme.colorScheme.onSurface, // Adaptable text
                  ),
                  onPressed: _isRevealed ? null : () => _handleAnswer(pokemon),
                  child: Text(
                    pokemon.name[0].toUpperCase() + pokemon.name.substring(1),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
