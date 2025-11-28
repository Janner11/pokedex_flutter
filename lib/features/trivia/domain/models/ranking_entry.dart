class RankingEntry {
  final String playerName;
  final int score;

  RankingEntry({required this.playerName, required this.score});

  factory RankingEntry.fromJson(Map<String, dynamic> json) {
    return RankingEntry(
      playerName: json['playerName'],
      score: json['score'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playerName': playerName,
      'score': score,
    };
  }
}
