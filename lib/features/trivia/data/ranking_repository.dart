import 'package:hive_flutter/hive_flutter.dart';

class RankingRepository {
  static const _boxName = 'trivia_scores';

  Box<Map> get _box => Hive.box<Map>(_boxName);

  /// Guarda un nuevo puntaje.
  Future<void> saveScore(String name, int score) async {
    final entry = {
      'name': name,
      'score': score,
      'date': DateTime.now().toIso8601String(),
    };
    // Usamos add para que se autogenere una key y no sobrescriba
    await _box.add(entry);
  }

  /// Obtiene los mejores 10 puntajes ordenados.
  List<Map<String, dynamic>> getTopScores() {
    final scores = _box.values.map((e) => Map<String, dynamic>.from(e)).toList();
    
    // Ordenar de mayor a menor
    scores.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
    
    // Retornar solo los top 10
    return scores.take(10).toList();
  }
}
