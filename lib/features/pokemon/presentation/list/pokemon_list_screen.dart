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
      body: Container(
        color: Theme.of(context).colorScheme.background,
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: mockList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.88,
          ),
          itemBuilder: (context, i) {
            final p = mockList[i];
            final base = typeColor(p.types.first, Theme.of(context).colorScheme.secondary);
            final bg = LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                base.withOpacity(.22),
                base.withOpacity(.08),
                base.withOpacity(.02),
              ],
              stops: const [0.0, 0.6, 1.0],
            );

            return InkWell(
              onTap: () => context.go("/pokemon/${p.id}"),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: bg,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Efecto de pokéball
                    Positioned(
                      right: -24,
                      top: -24,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              base.withOpacity(.12),
                              base.withOpacity(.04),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(14),
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
                                    color: Colors.grey[800],
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              PokedexBadge(id: p.id),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: p.types.map((t) => TypeChip(type: t)).toList(),
                          ),
                          const Spacer(),
                          Hero(
                            tag: "pkm-${p.id}",
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Image.network(
                                p.image,
                                height: 96,
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.medium,
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