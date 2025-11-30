import 'package:hive_flutter/hive_flutter.dart';

class AchievementsRepository {
  static const _boxName = 'trivia_achievements';

  // We assume the box is opened in main.dart
  Box<bool> get _box => Hive.box<bool>(_boxName);

  /// Marca un logro como desbloqueado.
  Future<void> unlockAchievement(String id) async {
    await _box.put(id, true);
  }

  /// Obtiene la lista de IDs de logros desbloqueados.
  Set<String> getUnlockedAchievements() {
    final keys = _box.keys.cast<String>().toSet();
    // Filter only those that are true, though we only store true.
    return keys.where((key) => _box.get(key) == true).toSet();
  }
  
  /// Verifica si un logro específico está desbloqueado.
  bool isUnlocked(String id) {
    return _box.get(id) == true;
  }
}
