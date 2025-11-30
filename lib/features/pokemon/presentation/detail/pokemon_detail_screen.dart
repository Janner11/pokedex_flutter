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
import '../widgets/matchups_view.dart';

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
          pokemon_v2_abilityflavortexts(where: {language_id: {_in: [7, 9]}}, limit: 1) {
            flavor_text
          }
        }
      }
      pokemon_v2_pokemonspecy {
        generation_id
        gender_rate
        pokemon_v2_pokemonegggroups {
          pokemon_v2_egggroup {
            name
          }
        }
        pokemon_v2_pokemonspeciesflavortexts(where: {language_id: {_in: [7, 9]}}, limit: 10) {
          flavor_text
          language_id
        }
        pokemon_v2_pokemons {
          id
          name
          is_default
        }
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
      pokemon_v2_pokemonmoves {
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
        pokemon_v2_versiongroup {
          name
        }
      }
    }
  }
""";

class PokemonDetailScreen extends StatefulWidget {
  final String id;
  const PokemonDetailScreen({super.key, required this.id});

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  final _favoritesRepo = FavoritesRepository();
  bool _showShiny = false;

  @override
  Widget build(BuildContext context) {
    final pid = int.tryParse(widget.id);
    final theme = Theme.of(context);
    // Color de superficie sutil para contenedores (adaptable a modo oscuro)
    final surfaceColor = theme.colorScheme.surfaceVariant.withOpacity(0.3);
    final borderColor = theme.colorScheme.outline.withOpacity(0.2);

    return Query(
        options: QueryOptions(
          document: gql(getPokemonDetail),
          variables: {'id': pid},
          fetchPolicy: FetchPolicy.cacheAndNetwork, 
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

          if (result.isLoading && result.data == null) {
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

          final totalStats = pokemon.stats.values.fold(0, (sum, val) => sum + val);

          final displayImage = _showShiny 
              ? (pokemon.shinyImageUrl.isNotEmpty ? pokemon.shinyImageUrl : pokemon.imageUrl)
              : pokemon.imageUrl;

          return Scaffold(
            appBar: PokedexAppBar(
              title: "${pokemon.name[0].toUpperCase()}${pokemon.name.substring(1)}  #${pokemon.id.toString().padLeft(4, '0')}",
              actions: [
                IconButton(
                  icon: const Icon(Icons.map),
                  onPressed: () {
                    context.push('/pokemon_map/${pokemon.name}/${pokemon.id}');
                  },
                ),
              ],
            ),
            floatingActionButton: ValueListenableBuilder<Box<int>>(
              valueListenable: _favoritesRepo.a_box.listenable(),
              builder: (context, box, child) {
                final isFavorite = _favoritesRepo.isFavorite(pokemon.id);
                return FloatingActionButton(
                  onPressed: () => _favoritesRepo.toggle(pokemon),
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
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Hero(
                                tag: "pkm-${pokemon.id}",
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  child: Image.network(
                                    displayImage,
                                    height: 200,
                                    fit: BoxFit.contain,
                                    filterQuality: FilterQuality.medium,
                                  ),
                                ),
                              ),
                              if (pokemon.shinyImageUrl.isNotEmpty)
                                IconButton(
                                  icon: Icon(
                                    Icons.auto_awesome,
                                    color: _showShiny ? Colors.amber : Colors.grey.withOpacity(0.5),
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _showShiny = !_showShiny;
                                    });
                                  },
                                  tooltip: "Ver Shiny",
                                ),
                            ],
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
                          _Section(title: "Acerca de"),
                          const SizedBox(height: 12),
                          
                          if (pokemon.variants.length > 1) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: surfaceColor, // 🔹 COLOR ADAPTABLE
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: borderColor),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  isExpanded: true,
                                  value: pokemon.id,
                                  dropdownColor: theme.colorScheme.surface, // Fondo del menú desplegable
                                  items: pokemon.variants.map((variant) {
                                    return DropdownMenuItem<int>(
                                      value: variant.id,
                                      child: Text(
                                        variant.name.replaceAll('-', ' ').capitalize(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: theme.colorScheme.onSurface, // Texto adaptable
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (newId) {
                                    if (newId != null && newId != pokemon.id) {
                                      context.pushReplacement('/pokemon/$newId');
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          if (pokemon.description.isNotEmpty) ...[
                            Text(
                              pokemon.description,
                              style: TextStyle(
                                fontSize: 15, 
                                height: 1.4, 
                                color: theme.colorScheme.onBackground.withOpacity(0.8), // Texto adaptable
                              ),
                              textAlign: TextAlign.justify,
                            ),
                            const SizedBox(height: 20),
                          ],
                          
                          // 🔹 FILA INFO (Altura, Peso...)
                          _buildInfoRow(pokemon, surfaceColor),
                          
                          if (pokemon.eggGroups.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Text("Grupos Huevo: ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                                ...pokemon.eggGroups.map((g) => Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Chip(
                                    label: Text(g.capitalize()),
                                    visualDensity: VisualDensity.compact,
                                    backgroundColor: surfaceColor, // 🔹 Fondo adaptable
                                    side: BorderSide(color: borderColor),
                                    labelStyle: TextStyle(
                                      fontWeight: FontWeight.w600, 
                                      color: theme.colorScheme.onSurface, // Texto adaptable
                                    ), 
                                  ),
                                )),
                              ],
                            ),
                          ],
                          const SizedBox(height: 24),
                          
                          _Section(title: "Estadísticas Base"),
                          const SizedBox(height: 24),
                          if (pokemon.stats.isNotEmpty) ...[
                            StatsRadarChart(stats: pokemon.stats, color: base),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: surfaceColor, // 🔹 Fondo adaptable
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                              ),
                              child: Column(
                                children: [
                                  ...pokemon.stats.entries.map((e) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      children: [
                                        SizedBox(width: 40, child: Text(e.key, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                                        Text("${e.value}", style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: LinearProgressIndicator(
                                            value: e.value / 255.0,
                                            backgroundColor: theme.colorScheme.surfaceVariant, // Fondo de barra adaptable
                                            color: _getStatColor(e.key, base),
                                            minHeight: 6,
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                                  Divider(color: borderColor),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("TOTAL", style: TextStyle(fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface)),
                                      Text("$totalStats", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: theme.colorScheme.onSurface)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                          
                          const SizedBox(height: 24),
                          _Section(title: "Debilidades"),
                          const SizedBox(height: 12),
                          MatchupsView(types: pokemon.types),

                          const SizedBox(height: 24),
                          _Section(title: "Habilidades"),
                          const SizedBox(height: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: pokemon.abilities.map((a) => Card(
                              elevation: 0,
                              color: surfaceColor, // 🔹 Fondo adaptable
                              shape: RoundedRectangleBorder(
                                side: BorderSide(color: borderColor),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          a.name.replaceAll('-', ' ').capitalize(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold, 
                                            fontSize: 15,
                                            color: theme.colorScheme.onSurface, // Texto adaptable
                                          ),
                                        ),
                                        if (a.isHidden) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.secondaryContainer, // Color sutil
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              "Oculta",
                                              style: TextStyle(
                                                fontSize: 10, 
                                                fontWeight: FontWeight.bold,
                                                color: theme.colorScheme.onSecondaryContainer, // Texto contrastado
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    if (a.description.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        a.description,
                                        style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant), // Texto secundario
                                      ),
                                    ]
                                  ],
                                ),
                              ),
                            )).toList(),
                          ),

                          const SizedBox(height: 24),
                          _Section(title: "Evoluciones"),
                          const SizedBox(height: 12),
                          EvolutionChainView(evolutionChain: pokemon.evolutionChain),

                          const SizedBox(height: 24),
                          _Section(title: "Movimientos"),
                          const SizedBox(height: 12),
                          MovesListView(moves: pokemon.moves, generationId: pokemon.generationId),
                          const SizedBox(height: 80),
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

  Color _getStatColor(String stat, Color baseColor) {
    switch (stat) {
      case 'HP': return Colors.green;
      case 'ATK': return Colors.orange;
      case 'DEF': return Colors.yellow[700]!;
      case 'SPA': return Colors.blue;
      case 'SPD': return Colors.purple;
      case 'SPE': return Colors.pink;
      default: return baseColor;
    }
  }

  Widget _buildInfoRow(Pokemon pokemon, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _InfoItem(
            label: "Altura", 
            value: "${(pokemon.height / 10).toStringAsFixed(1)} m",
            icon: Icons.height,
          ),
          _InfoItem(
            label: "Peso", 
            value: "${(pokemon.weight / 10).toStringAsFixed(1)} kg",
            icon: Icons.scale,
          ),
          _InfoItem(
            label: "Género", 
            value: _getGenderText(pokemon.genderRate),
            icon: _getGenderIcon(pokemon.genderRate),
            iconColor: _getGenderColor(pokemon.genderRate),
          ),
        ],
      ),
    );
  }

  String _getGenderText(int rate) {
    if (rate == -1) return "Sin género";
    if (rate == 0) return "100% ♂";
    if (rate == 8) return "100% ♀";
    if (rate > 0 && rate < 8) {
       final femaleRatio = (rate / 8.0) * 100;
       final maleRatio = 100 - femaleRatio;
       return "${maleRatio.toInt()}% ♂, ${femaleRatio.toInt()}% ♀";
    }
    return "Misto";
  }

  IconData _getGenderIcon(int rate) {
    if (rate == -1) return Icons.transgender;
    if (rate == 0) return Icons.male;
    if (rate == 8) return Icons.female;
    return Icons.people_alt;
  }

  Color _getGenderColor(int rate) {
    if (rate == -1) return Colors.grey;
    if (rate == 0) return Colors.blue;
    if (rate == 8) return Colors.pink;
    return Colors.purple;
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;

  const _InfoItem({
    required this.label, 
    required this.value, 
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: iconColor ?? Colors.grey[600], size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: theme.colorScheme.onSurface),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  const _Section({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.primary.withOpacity(0.2),
            width: 2,
          ),
        ),
      ),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: theme.colorScheme.onBackground.withOpacity(0.8), // Adaptable
        ),
      ),
    );
  }
}

extension StringExtension on String {
    String capitalize() {
      return "${this[0].toUpperCase()}${substring(1)}";
    }
}
