import 'package:flutter/material.dart';
import '../../data/ranking_repository.dart';
import '../../domain/models/ranking_entry.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final _rankingRepo = RankingRepository();
  late Future<List<RankingEntry>> _rankingFuture;

  @override
  void initState() {
    super.initState();
    _rankingFuture = _rankingRepo.getRanking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ranking de Trivia'),
      ),
      body: FutureBuilder<List<RankingEntry>>(
        future: _rankingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar el ranking.'));
          }

          final ranking = snapshot.data ?? [];

          if (ranking.isEmpty) {
            return const Center(
              child: Text(
                'Aún no hay puntuaciones. ¡Juega para ser el primero!',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            itemCount: ranking.length,
            itemBuilder: (context, index) {
              final entry = ranking[index];
              return ListTile(
                leading: Text(
                  '#${index + 1}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                title: Text(entry.playerName, style: const TextStyle(fontSize: 18)),
                trailing: Text(
                  '${entry.score} pts',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
