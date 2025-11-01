import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/pokemon.dart';

class EvolutionChainView extends StatelessWidget {
  final List<Evolution> evolutionChain;
  const EvolutionChainView({super.key, required this.evolutionChain});

  @override
  Widget build(BuildContext context) {
    // If the pokemon doesn't evolve, show an empty state.
    if (evolutionChain.length < 2) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("Este Pokémon no tiene evoluciones.",
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: evolutionChain.map((evo) {
          final isLast = evo == evolutionChain.last;
          return Row(
            children: [
              _EvolutionCard(evolution: evo),
              if (!isLast)
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 20),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _EvolutionCard extends StatelessWidget {
  final Evolution evolution;
  const _EvolutionCard({required this.evolution});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => context.push('/pokemon/${evolution.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Image.network(
                evolution.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.contain,
                // Show a placeholder if image is missing
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                evolution.name[0].toUpperCase() + evolution.name.substring(1),
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
