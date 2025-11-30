import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'trivia_title': 'Who\'s that Pokémon?',
      'start_game': 'START GAME',
      'play_again': 'Play Again',
      'score': 'Score',
      'streak': 'Streak',
      'time': 'Time',
      'game_over': 'Game Over!',
      'final_score': 'Final Score',
      'save_ranking': 'Save Ranking',
      'your_name': 'Your Name',
      'trainer': 'Trainer',
      'exit': 'Quit',
      'loading': 'Loading trivia...',
      'error_loading': 'Error loading Pokémon',
      'retry': 'Retry',
      'achievement_unlocked': 'Achievement Unlocked!',
      'ranking': 'Ranking',
      'achievements': 'Achievements',
      'guess_instruction': 'You have 10 seconds to guess who is behind the silhouette.',
      'pokedex': 'Pokédex',
      'favorites': 'Favorites',
      'about': 'About',
      'stats': 'Base Stats',
      'weaknesses': 'Weaknesses',
      'abilities': 'Abilities',
      'evolutions': 'Evolutions',
      'moves': 'Moves',
      'height': 'Height',
      'weight': 'Weight',
      'gender': 'Gender',
      'egg_groups': 'Egg Groups',
    },
    'es': {
      'trivia_title': '¿Quién es este Pokémon?',
      'start_game': 'INICIAR JUEGO',
      'play_again': 'Jugar de nuevo',
      'score': 'Puntos',
      'streak': 'Racha',
      'time': 'Tiempo',
      'game_over': '¡Fin del juego!',
      'final_score': 'Puntuación final',
      'save_ranking': 'Guardar Ranking',
      'your_name': 'Tu nombre',
      'trainer': 'Entrenador',
      'exit': 'Salir',
      'loading': 'Cargando trivia...',
      'error_loading': 'Error al cargar Pokémon',
      'retry': 'Reintentar',
      'achievement_unlocked': '¡Logro desbloqueado!',
      'ranking': 'Ranking',
      'achievements': 'Logros',
      'guess_instruction': 'Tienes 10 segundos para adivinar quién se esconde detrás de la silueta.',
      'pokedex': 'Pokédex',
      'favorites': 'Favoritos',
      'about': 'Acerca de',
      'stats': 'Estadísticas Base',
      'weaknesses': 'Debilidades',
      'abilities': 'Habilidades',
      'evolutions': 'Evoluciones',
      'moves': 'Movimientos',
      'height': 'Altura',
      'weight': 'Peso',
      'gender': 'Género',
      'egg_groups': 'Grupos Huevo',
    },
  };

  String get triviaTitle => _localizedValues[locale.languageCode]!['trivia_title']!;
  String get startGame => _localizedValues[locale.languageCode]!['start_game']!;
  String get playAgain => _localizedValues[locale.languageCode]!['play_again']!;
  String get score => _localizedValues[locale.languageCode]!['score']!;
  String get streak => _localizedValues[locale.languageCode]!['streak']!;
  String get time => _localizedValues[locale.languageCode]!['time']!;
  String get gameOver => _localizedValues[locale.languageCode]!['game_over']!;
  String get finalScore => _localizedValues[locale.languageCode]!['final_score']!;
  String get saveRanking => _localizedValues[locale.languageCode]!['save_ranking']!;
  String get yourName => _localizedValues[locale.languageCode]!['your_name']!;
  String get trainer => _localizedValues[locale.languageCode]!['trainer']!;
  String get exit => _localizedValues[locale.languageCode]!['exit']!;
  String get loading => _localizedValues[locale.languageCode]!['loading']!;
  String get errorLoading => _localizedValues[locale.languageCode]!['error_loading']!;
  String get retry => _localizedValues[locale.languageCode]!['retry']!;
  String get achievementUnlocked => _localizedValues[locale.languageCode]!['achievement_unlocked']!;
  String get ranking => _localizedValues[locale.languageCode]!['ranking']!;
  String get achievements => _localizedValues[locale.languageCode]!['achievements']!;
  String get guessInstruction => _localizedValues[locale.languageCode]!['guess_instruction']!;
  
  // General App Strings
  String get pokedex => _localizedValues[locale.languageCode]!['pokedex']!;
  String get favorites => _localizedValues[locale.languageCode]!['favorites']!;
  String get about => _localizedValues[locale.languageCode]!['about']!;
  String get stats => _localizedValues[locale.languageCode]!['stats']!;
  String get weaknesses => _localizedValues[locale.languageCode]!['weaknesses']!;
  String get abilities => _localizedValues[locale.languageCode]!['abilities']!;
  String get evolutions => _localizedValues[locale.languageCode]!['evolutions']!;
  String get moves => _localizedValues[locale.languageCode]!['moves']!;
  String get height => _localizedValues[locale.languageCode]!['height']!;
  String get weight => _localizedValues[locale.languageCode]!['weight']!;
  String get gender => _localizedValues[locale.languageCode]!['gender']!;
  String get eggGroups => _localizedValues[locale.languageCode]!['egg_groups']!;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'es'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
