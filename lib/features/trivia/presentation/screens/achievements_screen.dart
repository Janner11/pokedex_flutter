import 'package:flutter/material.dart';
import '../../data/achievements_repository.dart';
import '../../domain/models/achievement.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final _achievementsRepo = AchievementsRepository();
  Set<String> _unlockedIds = {};

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  void _loadAchievements() {
    setState(() {
      _unlockedIds = _achievementsRepo.getUnlockedAchievements();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logros'),
      ),
      body: ListView.builder(
        itemCount: allAchievements.length,
        itemBuilder: (context, index) {
          final achievement = allAchievements[index];
          final isUnlocked = _unlockedIds.contains(achievement.id);

          return ListTile(
            leading: Icon(
              isUnlocked ? Icons.emoji_events_rounded : Icons.lock_outline_rounded,
              size: 40,
              color: isUnlocked ? Colors.amber : Colors.grey,
            ),
            title: Text(
              achievement.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                // 🔹 Color adaptable: si desbloqueado, usa color del tema; si no, gris
                color: isUnlocked ? theme.colorScheme.onBackground : Colors.grey,
              ),
            ),
            subtitle: Text(
              achievement.description,
              style: TextStyle(
                // 🔹 Color adaptable con opacidad
                color: isUnlocked ? theme.colorScheme.onBackground.withOpacity(0.7) : Colors.grey,
              ),
            ),
          );
        },
      ),
    );
  }
}
