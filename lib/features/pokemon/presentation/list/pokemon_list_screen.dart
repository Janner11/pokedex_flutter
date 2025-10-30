import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../pokemon/data/mock.dart';
import '../../../pokemon/data/type_colors.dart';
import '../widgets/type_chip.dart';
import '../widgets/pokedex_appbar.dart';
import '../widgets/pokedex_badge.dart';

class PokemonListScreen extends StatelessWidget {
  const PokemonListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PokedexAppBar(title: "Pokédex"),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          itemCount: mockList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: .84,
          ),
          itemBuilder: (context, i) {
            final p = mockList[i];
            final base = typeColor(p.types.first, Theme.of(context).colorScheme.secondary);
            final bg = LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                base.withOpacity(.18),
                base.withOpacity(.06),
              ],
            );

            return InkWell(
              onTap: () => context.go("/pokemon/${p.id}"),
              borderRadius: BorderRadius.circular(18),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: bg,
                ),
                child: Stack(
                  children: [
                    // Sutil “disco” tipo pokéball
                    Positioned(
                      right: -18,
                      top: -18,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: base.withOpacity(.08),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  p.name[0].toUpperCase() + p.name.substring(1),
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              PokedexBadge(id: p.id),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: -6,
                            children: p.types.map((t) => TypeChip(type: t)).toList(),
                          ),
                          const Spacer(),
                          Hero(
                            tag: "pkm-${p.id}",
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Image.network(
                                p.image,
                                height: 110,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
