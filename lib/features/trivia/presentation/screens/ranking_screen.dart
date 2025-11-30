import 'package:flutter/material.dart';
import '../../data/ranking_repository.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final _rankingRepo = RankingRepository();
  List<Map<String, dynamic>> _ranking = [];

  @override
  void initState() {
    super.initState();
    _loadRanking();
  }

  void _loadRanking() {
    setState(() {
      _ranking = _rankingRepo.getTopScores();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ranking de Trivia'),
      ),
      body: _ranking.isEmpty
          ? Center(
              child: Text(
                'Aún no hay puntuaciones.\n¡Juega para ser el primero!',
                style: TextStyle(fontSize: 18, color: theme.colorScheme.onBackground),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: _ranking.length,
              itemBuilder: (context, index) {
                final entry = _ranking[index];
                final isTop3 = index < 3;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isTop3 ? Colors.amber : theme.colorScheme.surfaceVariant,
                    foregroundColor: isTop3 ? Colors.white : theme.colorScheme.onSurfaceVariant,
                    child: Text('${index + 1}'),
                  ),
                  title: Text(
                    entry['name'] ?? 'Jugador',
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground, // 🔹 Adaptable
                    ),
                  ),
                  trailing: Text(
                    '${entry['score']} pts',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: theme.colorScheme.secondary),
                  ),
                );
              },
            ),
    );
  }
}
