import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/pokemon.dart';

class EvolutionChainView extends StatelessWidget {
  final List<EvolutionNode> evolutionChain;
  const EvolutionChainView({super.key, required this.evolutionChain});

  @override
  Widget build(BuildContext context) {
    if (evolutionChain.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("Este Pokémon no tiene evoluciones.",
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
        ),
      );
    }

    // The root of the tree, starting with indentation level 0
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: evolutionChain.map((node) => _EvolutionNodeWidget(node: node)).toList(),
    );
  }
}

/// A recursive widget that displays a node and its children.
class _EvolutionNodeWidget extends StatelessWidget {
  final EvolutionNode node;
  final int level;
  const _EvolutionNodeWidget({required this.node, this.level = 0});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          // Indent the card based on its level in the tree
          padding: EdgeInsets.only(left: level * 16.0),
          child: Row(
            children: [
              // Show arrow for nodes that are not at the root
              if (level > 0) ...[
                const Icon(Icons.subdirectory_arrow_right, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
              ],
              _EvolutionCard(evolution: node),
            ],
          ),
        ),
        // --- RECURSION ---
        // Render the children of the current node, increasing the indentation level
        ...node.evolutions.map((evo) => _EvolutionNodeWidget(node: evo, level: level + 1)),
      ],
    );
  }
}

/// The visual card for a single Pokémon in the chain.
class _EvolutionCard extends StatelessWidget {
  final EvolutionNode evolution;
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
            mainAxisSize: MainAxisSize.min, // Make the card only as wide as needed
            children: [
              Image.network(
                evolution.imageUrl,
                width: 70,
                height: 70,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported, size: 70, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    evolution.name[0].toUpperCase() + evolution.name.substring(1),
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  // Display the evolution trigger if it exists
                  if (evolution.trigger.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      evolution.trigger,
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ]
                ],
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }
}
