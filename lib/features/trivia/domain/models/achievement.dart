class Achievement {
  final String id;
  final String name;
  final String description;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
  });
}

const List<Achievement> allAchievements = [
  Achievement(
    id: 'first_guess',
    name: 'Primeros Pasos',
    description: 'Adivina tu primer Pokémon.',
  ),
  Achievement(
    id: 'streak_5',
    name: 'Racha de 5',
    description: 'Adivina 5 Pokémon seguidos.',
  ),
  Achievement(
    id: 'score_100',
    name: 'Puntuación de 100',
    description: 'Alcanza una puntuación de 100.',
  ),
  Achievement(
    id: 'score_500',
    name: 'Maestro Pokémon',
    description: 'Alcanza una puntuación de 500.',
  ),
];
