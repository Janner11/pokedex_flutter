import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/favorites_repository.dart';
import '../../domain/models/pokemon.dart';
import '../../../pokemon/data/type_colors.dart';
import '../widgets/error_view.dart';
import '../widgets/evolution_chain_view.dart';
import '../widgets/moves_list_view.dart';
import '../widgets/stats_radar_chart.dart';
import '../widgets/type_chip.dart';
import '../widgets/pokedex_appbar.dart';

const getPokemonDetail = r"""
  query GetPokemonDetail($id: Int!) {
    pokemon_v2_pokemon_by_pk(id: $id) {
      id
      name
      height
      weight
      pokemon_v2_pokemontypes {
        pokemon_v2_type {
          name
        }
      }
      pokemon_v2_pokemonsprites {
        sprites
      }
      pokemon_v2_pokemonstats {
        base_stat
        pokemon_v2_stat {
          name
        }
      }
      pokemon_v2_pokemonabilities {
        is_hidden
        pokemon_v2_ability {
          name
        }
      }
      pokemon_v2_pokemonspecy {
        pokemon_v2_evolutionchain {
          pokemon_v2_pokemonspecies(order_by: {order: asc}) {
            id
            name
            evolves_from_species_id
            pokemon_v2_pokemons {
              pokemon_v2_pokemonsprites {
                sprites
              }
            }
            pokemon_v2_pokemonevolutions {
              min_level
              min_happiness
              time_of_day
              known_move_type_id
              pokemon_v2_item {
                name
              }
              pokemon_v2_evolutiontrigger {
                name
              }
              pokemon_v2_location {
                name
              }
            }
          }
        }
      }
      pokemon_v2_pokemonmoves(where: {pokemon_v2_versiongroup: {name: {_eq: "scarlet-violet"}}}) {
        level
        pokemon_v2_move {
          name
          power
          pp
          pokemon_v2_type {
            name
          }
        }
        pokemon_v2_movelearnmethod {
          name
        }
      }
    }
  }
"""
;

class PokemonDetailScreen extends StatefulWidget {
  final String id;
  const PokemonDetailScreen({super.key, required this.id});

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  final _favoritesRepo = FavoritesRepository();

  @override
  Widget build(BuildContext context) {
    final pid = int.tryParse(widget.id);

    return Query(
        options: QueryOptions(
          document: gql(getPokemonDetail),
          variables: {'id': pid},
        ),
        builder: (QueryResult result, {refetch, fetchMore}) {
          final p = result.data?['pokemon_v2_pokemon_by_pk'];

          if (result.hasException || (result.data != null && p == null)) {
            return Scaffold(
              appBar: const PokedexAppBar(),
              body: ErrorView(
                message: "No se pudo encontrar el Pokémon solicitado.",
                onRetry: () => refetch!(),
              ),
            );
          }

          if (result.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final pokemon = Pokemon.fromMap(p);

          final base = pokemon.types.isNotEmpty ? typeColor(pokemon.types.first, Theme.of(context).colorScheme.secondary) : Colors.grey;
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
              title: "${pokemon.name[0].toUpperCase()}${pokemon.name.substring(1)}  #${pokemon.id.toString().padLeft(4, '0')}",
            ),
            floatingActionButton: ValueListenableBuilder<Box<int>>(
              valueListenable: _favoritesRepo.a_box.listenable(),
              builder: (context, box, child) {
                final isFavorite = _favoritesRepo.isFavorite(pokemon.id);
                return FloatingActionButton(
                  onPressed: () => _favoritesRepo.toggle(pokemon.id),
                  elevation: 4,
                  child: Icon(
                    isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isFavorite ? Colors.red : null,
                  ),
                );
              },
            ),
            body: Container(
              color: Theme.of(context).colorScheme.background,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                      decoration: BoxDecoration(gradient: headerGrad),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Hero(
                            tag: "pkm-${pokemon.id}",
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              child: Image.network(
                                pokemon.imageUrl,
                                height: 200,
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.medium,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            children: pokemon.types.map((t) => TypeChip(type: t)).toList(),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _Section(title: "Estadísticas Base"),
                          const SizedBox(height: 24),
                          if (pokemon.stats.isNotEmpty)
                            StatsRadarChart(stats: pokemon.stats, color: base),
                          const SizedBox(height: 24),
                          _Section(title: "Habilidades"),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            children: pokemon.abilities.map((a) => Chip(
                              label: Text(a.replaceAll('-', ' ')),
                              backgroundColor: Colors.grey[200],
                              labelStyle: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[800]),
                            )).toList(),
                          ),
                          const SizedBox(height: 24),
                          _Section(title: "Evoluciones"),
                          const SizedBox(height: 12),
                          EvolutionChainView(evolutionChain: pokemon.evolutionChain),
                          const SizedBox(height: 24),
                          _Section(title: "Movimientos"),
                          const SizedBox(height: 12),
                          MovesListView(moves: pokemon.moves),
                          const SizedBox(height: 80), // Space for FloatingActionButton
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
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
