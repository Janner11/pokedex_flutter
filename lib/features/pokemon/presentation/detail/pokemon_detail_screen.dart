import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../pokemon/data/mock.dart';
import '../../../pokemon/data/type_colors.dart';
import '../widgets/type_chip.dart';
import '../widgets/stat_bar.dart';
import '../widgets/pokedex_appbar.dart';

class PokemonDetailScreen extends StatelessWidget {
  final String id;
  const PokemonDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final pid = int.tryParse(id);
    final detail = pid != null ? mockDetails[pid] : null;

    if (detail == null) {
      return Scaffold(
        appBar: const PokedexAppBar(),
        body: Container(
          color: Theme.of(context).colorScheme.background,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  "Pokémon no encontrado",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final base = typeColor(detail.types.first, Theme.of(context).colorScheme.secondary);
    final headerGrad = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        base.withOpacity(.25),
        base.withOpacity(.10),
        Theme.of(context).colorScheme.background,
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    return Scaffold(
      appBar: PokedexAppBar(
        title: "${detail.name[0].toUpperCase()}${detail.name.substring(1)}  #${detail.id.toString().padLeft(4, '0')}",
      ),
      body: Container(
        color: Theme.of(context).colorScheme.background,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // HEADER MEJORADO
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                decoration: BoxDecoration(gradient: headerGrad),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Hero(
                      tag: "pkm-${detail.id}",
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: Image.network(
                          detail.image,
                          height: 200,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.medium,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: detail.types.map((t) => TypeChip(type: t)).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // BODY MEJORADO
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Section(title: "Estadísticas"),
                    const SizedBox(height: 16),
                    ...detail.stats.entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: StatBar(name: e.key, value: e.value),
                    )),

                    const SizedBox(height: 24),
                    _Section(title: "Habilidades"),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: detail.abilities.map((a) => Chip(
                        label: Text(
                          a,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      )).toList(),
                    ),

                    const SizedBox(height: 24),
                    _Section(title: "Movimientos"),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: detail.moves.take(12).map((m) => Chip(
                        label: Text(
                          m,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        visualDensity: VisualDensity.compact,
                      )).toList(),
                    ),

                    if (detail.evolutions.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _Section(title: "Evoluciones"),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 10,
                        children: detail.evolutions.map((e) {
                          return ActionChip(
                            label: Text(
                              e["name"],
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            avatar: const Icon(Icons.arrow_forward, size: 16),
                            onPressed: () => context.go('/pokemon/${e["id"]}'),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  const _Section({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            width: 2,
          ),
        ),
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: Colors.grey[800],
        ),
      ),
    );
  }
}