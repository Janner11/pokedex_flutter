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
  late Future<Set<String>> _unlockedAchievementsFuture;

  @override
  void initState() {
    super.initState();
    _unlockedAchievementsFuture = _achievementsRepo.getUnlockedAchievements();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logros'),
      ),
      body: FutureBuilder<Set<String>>(
        future: _unlockedAchievementsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los logros.'));
          }

          final unlockedIds = snapshot.data ?? {};

          return ListView.builder(
            itemCount: allAchievements.length,
            itemBuilder: (context, index) {
              final achievement = allAchievements[index];
              final isUnlocked = unlockedIds.contains(achievement.id);

              return ListTile(
                leading: Icon(
                  isUnlocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                  size: 40,
                  color: isUnlocked ? Colors.amber : Colors.grey,
                ),
                title: Text(
                  achievement.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? Colors.black : Colors.grey,
                  ),
                ),
                subtitle: Text(
                  achievement.description,
                  style: TextStyle(
                    color: isUnlocked ? Colors.black54 : Colors.grey,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
