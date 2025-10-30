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
      return const Scaffold(
        appBar: PokedexAppBar(),
        body: Center(child: Text("Pokémon no encontrado")),
      );
    }

    final base = typeColor(detail.types.first, Theme.of(context).colorScheme.secondary);
    final headerGrad = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [base.withOpacity(.20), base.withOpacity(.06)],
    );

    return Scaffold(
      appBar: PokedexAppBar(title: "${detail.name[0].toUpperCase()}${detail.name.substring(1)}  #${detail.id}"),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              decoration: BoxDecoration(gradient: headerGrad),
              child: Column(
                children: [
                  Hero(
                    tag: "pkm-${detail.id}",
                    child: Image.network(detail.image, height: 210, fit: BoxFit.contain),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    children: detail.types.map((t) => TypeChip(type: t)).toList(),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            // BODY
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Section(title: "Estadísticas"),
                  const SizedBox(height: 10),
                  ...detail.stats.entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: StatBar(name: e.key, value: e.value),
                  )),

                  const SizedBox(height: 18),
                  _Section(title: "Habilidades"),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: detail.abilities.map((a) => Chip(label: Text(a))).toList(),
                  ),

                  const SizedBox(height: 18),
                  _Section(title: "Movimientos"),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: detail.moves.take(12).map((m) => Chip(label: Text(m))).toList(),
                  ),

                  const SizedBox(height: 18),
                  _Section(title: "Evoluciones"),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: detail.evolutions.map((e) {
                      return ActionChip(
                        label: Text(e["name"]),
                        onPressed: () => context.go('/pokemon/${e["id"]}'),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
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
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}
