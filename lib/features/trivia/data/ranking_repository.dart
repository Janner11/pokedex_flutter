import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/ranking_entry.dart';

class RankingRepository {
  static const _rankingKey = 'trivia_ranking';
  static const _maxEntries = 10;

  Future<List<RankingEntry>> getRanking() async {
    final prefs = await SharedPreferences.getInstance();
    final rankingJson = prefs.getStringList(_rankingKey) ?? [];
    return rankingJson
        .map((e) => RankingEntry.fromJson(jsonDecode(e)))
        .toList();
  }

  Future<void> saveScore(String playerName, int score) async {
    final prefs = await SharedPreferences.getInstance();
    final ranking = await getRanking();

    ranking.add(RankingEntry(playerName: playerName, score: score));
    ranking.sort((a, b) => b.score.compareTo(a.score));

    final newRanking = ranking.take(_maxEntries).toList();

    final rankingJson = newRanking
        .map((e) => jsonEncode(e.toJson()))
        .toList();
    await prefs.setStringList(_rankingKey, rankingJson);
  }
}
