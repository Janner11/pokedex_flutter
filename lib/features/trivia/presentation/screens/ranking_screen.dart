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
    // Hive is synchronous once opened, so we can just get the data
    setState(() {
      _ranking = _rankingRepo.getTopScores();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ranking de Trivia'),
      ),
      body: _ranking.isEmpty
          ? const Center(
              child: Text(
                'Aún no hay puntuaciones.\n¡Juega para ser el primero!',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: _ranking.length,
              itemBuilder: (context, index) {
                final entry = _ranking[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: index < 3 ? Colors.amber : Colors.grey[300],
                    foregroundColor: index < 3 ? Colors.white : Colors.black,
                    child: Text('${index + 1}'),
                  ),
                  title: Text(
                    entry['name'] ?? 'Jugador',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    '${entry['score']} pts',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.blue),
                  ),
                );
              },
            ),
    );
  }
}
