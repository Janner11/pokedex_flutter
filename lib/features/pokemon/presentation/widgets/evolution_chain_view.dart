import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/pokemon.dart';

class EvolutionChainView extends StatelessWidget {
  final List<Evolution> evolutionChain;
  const EvolutionChainView({super.key, required this.evolutionChain});

  @override
  Widget build(BuildContext context) {
    if (evolutionChain.isEmpty || (evolutionChain.length == 1 && evolutionChain.first.evolutions.isEmpty)) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("Este Pokémon no tiene evoluciones.",
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: evolutionChain.map((evo) => _EvolutionNode(evolution: evo)).toList(),
    );
  }
}

class _EvolutionNode extends StatelessWidget {
  final Evolution evolution;
  final int level;
  const _EvolutionNode({required this.evolution, this.level = 0});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: level * 16.0),
          child: Row(
            children: [
              if (level > 0) ...[
                const Icon(Icons.subdirectory_arrow_right, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
              ],
              _EvolutionCard(evolution: evolution),
            ],
          ),
        ),
        ...evolution.evolutions.map((evo) => _EvolutionNode(evolution: evo, level: level + 1)),
      ],
    );
  }
}

class _EvolutionCard extends StatelessWidget {
  final Evolution evolution;
  const _EvolutionCard({required this.evolution});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () => context.push('/pokemon/${evolution.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Image.network(
                evolution.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    evolution.name[0].toUpperCase() + evolution.name.substring(1),
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (evolution.evolutionDetails.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      evolution.evolutionDetails,
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ]
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
