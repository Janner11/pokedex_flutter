import 'package:shared_preferences/shared_preferences.dart';

class AchievementsRepository {
  static const _achievementsKey = 'trivia_achievements';

  Future<Set<String>> getUnlockedAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_achievementsKey) ?? []).toSet();
  }

  Future<void> unlockAchievement(String achievementId) async {
    final prefs = await SharedPreferences.getInstance();
    final unlocked = await getUnlockedAchievements();
    unlocked.add(achievementId);
    await prefs.setStringList(_achievementsKey, unlocked.toList());
  }
}
