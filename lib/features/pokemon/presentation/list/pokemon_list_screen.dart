import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../main.dart'; // 🔹 Importar para acceder a themeProvider
import '../../data/favorites_repository.dart';
import '../../domain/models/pokemon.dart';
import '../../../pokemon/data/type_colors.dart';
import '../widgets/error_view.dart';
import '../widgets/type_chip.dart';
import '../widgets/pokedex_appbar.dart';
import '../widgets/pokedex_badge.dart';
import '../widgets/filter_dialog.dart';

const getPokemonList = r"""
  query GetPokemonList($limit: Int!, $offset: Int!, $where: pokemon_v2_pokemon_bool_exp, $order_by: [pokemon_v2_pokemon_order_by!]) {
    pokemon_v2_pokemon(limit: $limit, offset: $offset, order_by: $order_by, where: $where) {
      id
      name
      pokemon_v2_pokemonspecy {
        generation_id
      }
      pokemon_v2_pokemontypes {
        pokemon_v2_type {
          name
        }
      }
      pokemon_v2_pokemonsprites {
        sprites
      }
    }
  }
""";

const int _pokemonPageLimit = 30;

class PokemonListScreen extends StatefulWidget {
  const PokemonListScreen({super.key});

  @override
  State<PokemonListScreen> createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  final ScrollController _scrollController = ScrollController();
  final _favoritesRepo = FavoritesRepository();
  String _searchTerm = '';
  Timer? _debounce;
  Box? _cacheBox;
  bool _isCaching = false;

  // Filter and sort state
  String? _selectedType;
  int? _selectedGeneration;
  String _sortBy = 'id';
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _openCacheBox();
  }

  Future<void> _openCacheBox() async {
    _cacheBox = await Hive.openBox('pokemon_list_cache');
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() {
        _searchTerm = query;
      });
    });
  }

  // --- IMAGE PERSISTENCE LOGIC ---
  Future<void> _cacheImagesAndSave(List<dynamic> rawList) async {
    if (_cacheBox == null) return;
    
    if (mounted) setState(() => _isCaching = true);

    final List<Map<String, dynamic>> processedList = [];
    final httpClient = HttpClient();

    for (var item in rawList) {
      final mapItem = Map<String, dynamic>.from(item);
      
      if (mapItem['imageBase64'] != null) {
        processedList.add(mapItem);
        continue;
      }

      String imageUrl = '';
      try {
        dynamic spritesField = mapItem['pokemon_v2_pokemonsprites'][0]['sprites'];
        Map<String, dynamic> spritesMap = {};
        if (spritesField is String) {
          spritesMap = jsonDecode(spritesField);
        } else {
          spritesMap = spritesField;
        }
        imageUrl = spritesMap['other']?['official-artwork']?['front_default'] ?? spritesMap['front_default'] ?? '';
      } catch (e) {
        // Ignore parsing errors
      }

      if (imageUrl.isNotEmpty) {
        try {
          final request = await httpClient.getUrl(Uri.parse(imageUrl));
          final response = await request.close();
          if (response.statusCode == 200) {
            final bytes = await consolidateHttpClientResponseBytes(response);
            final base64Image = base64Encode(bytes);
            mapItem['imageBase64'] = base64Image;
          }
        } catch (e) {
          // Failed to download image
        }
      }
      processedList.add(mapItem);
    }

    await _cacheBox!.put('last_list', processedList);
    
    if (mounted) setState(() => _isCaching = false);
  }
  // -------------------------------

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return FilterDialog(
          selectedType: _selectedType,
          selectedGeneration: _selectedGeneration,
          sortBy: _sortBy,
          sortAscending: _sortAscending,
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          _selectedType = value['type'];
          _selectedGeneration = value['generation'];
          _sortBy = value['sortBy'];
          _sortAscending = value['sortAscending'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final whereClauses = <Map<String, dynamic>>[];
    if (_searchTerm.isNotEmpty) {
      whereClauses.add({'name': {'_ilike': '%$_searchTerm%'}});
    }
    if (_selectedType != null) {
      whereClauses.add({
        'pokemon_v2_pokemontypes': {
          'pokemon_v2_type': {
            'name': {'_eq': _selectedType}
          }
        }
      });
    }
    if (_selectedGeneration != null) {
      whereClauses.add({
        'pokemon_v2_pokemonspecy': {
          'generation_id': {'_eq': _selectedGeneration}
        }
      });
    }

    final where = whereClauses.isEmpty
        ? null
        : whereClauses.length == 1
            ? whereClauses.first
            : {'_and': whereClauses};

    final orderBy = [
      {_sortBy: _sortAscending ? 'asc' : 'desc'}
    ];

    final queryVars = {
      'limit': _pokemonPageLimit,
      'offset': 0,
      'where': where,
      'order_by': orderBy,
    };

    return Scaffold(
      appBar: PokedexAppBar(
        title: "Pokédex",
        actions: [
          // 🔹 BOTÓN DE MODO OSCURO
          ListenableBuilder(
            listenable: themeProvider,
            builder: (context, _) {
              return IconButton(
                icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                onPressed: () => themeProvider.toggleTheme(),
                tooltip: "Cambiar tema",
              );
            },
          ),
          // -----------------------
          if (_isCaching)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: SizedBox(
                width: 16, 
                height: 16, 
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
              ),
            ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Buscar Pokémon...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          Expanded(
            child: Query(
              options: QueryOptions(
                document: gql(getPokemonList),
                variables: queryVars,
                fetchPolicy: FetchPolicy.cacheAndNetwork, 
              ),
              builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
                List<Pokemon> pokemonList = [];
                bool isOfflineMode = false;

                if (result.hasException) {
                  if (_cacheBox != null && _cacheBox!.containsKey('last_list')) {
                    try {
                      final cachedData = _cacheBox!.get('last_list');
                      if (cachedData is List) {
                        pokemonList = cachedData
                            .map((e) => Pokemon.fromMap(Map<String, dynamic>.from(e)))
                            .toList();
                        isOfflineMode = true;
                      }
                    } catch (e) {
                      return ErrorView(onRetry: () => refetch!());
                    }
                  } else {
                    return ErrorView(onRetry: () => refetch!());
                  }
                } else if (result.isLoading && result.data == null) {
                   return const Center(child: CircularProgressIndicator());
                } else {
                  final pokemonListRaw = result.data?['pokemon_v2_pokemon'] as List? ?? [];
                  pokemonList = pokemonListRaw.map((p) => Pokemon.fromMap(p)).toList();
                  
                  if (_cacheBox != null && pokemonListRaw.isNotEmpty && !_isCaching) {
                    Future.microtask(() => _cacheImagesAndSave(pokemonListRaw));
                  }
                }

                if (pokemonList.isEmpty && !result.isLoading) {
                  return const Center(child: Text("No se encontraron resultados"));
                }

                if (!isOfflineMode) {
                  _scrollController.addListener(() {
                    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
                      if (result.isLoading || fetchMore == null) return;

                      FetchMoreOptions opts = FetchMoreOptions(
                        variables: {'offset': pokemonList.length},
                        updateQuery: (previousResultData, fetchMoreResultData) {
                          final List<dynamic> repos = [
                            ...previousResultData!['pokemon_v2_pokemon'] as List<dynamic>,
                            ...fetchMoreResultData!['pokemon_v2_pokemon'] as List<dynamic>
                          ];
                          fetchMoreResultData['pokemon_v2_pokemon'] = repos;
                          
                          final newItems = fetchMoreResultData!['pokemon_v2_pokemon'] as List<dynamic>;
                          if (!_isCaching) {
                             Future.microtask(() => _cacheImagesAndSave(newItems));
                          }
                          
                          return fetchMoreResultData;
                        },
                      );
                      fetchMore(opts);
                    }
                  });
                }

                return Container(
                  color: Theme.of(context).colorScheme.background,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Column(
                    children: [
                      if (isOfflineMode)
                        Container(
                          width: double.infinity,
                          color: Colors.orange.shade100,
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(bottom: 8),
                          child: const Text(
                            "Modo Offline: Mostrando última lista guardada",
                            style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      Expanded(
                        child: GridView.builder(
                          controller: _scrollController,
                          itemCount: pokemonList.length + (result.isLoading ? 1 : 0),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.88,
                          ),
                          itemBuilder: (context, i) {
                            if (i == pokemonList.length) {
                              return const Center(child: CircularProgressIndicator());
                            }
                        
                            final p = pokemonList[i];
                        
                            final base = p.types.isNotEmpty ? typeColor(p.types.first, Theme.of(context).colorScheme.secondary) : Colors.grey;
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
                              onTap: () => context.push('/pokemon/${p.id}'),
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
                                                    // Adapt text color for dark mode if needed, 
                                                    // but card has custom gradient background so grey[800] is usually fine.
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
                                              child: p.imageBase64 != null
                                                  ? Image.memory(
                                                      base64Decode(p.imageBase64!),
                                                      height: 96,
                                                      fit: BoxFit.contain,
                                                    )
                                                  : CachedNetworkImage(
                                                      imageUrl: p.imageUrl,
                                                      height: 96,
                                                      fit: BoxFit.contain,
                                                      filterQuality: FilterQuality.medium,
                                                      placeholder: (context, url) => const SizedBox(
                                                        width: 96,
                                                        height: 96,
                                                        child: Center(child: CircularProgressIndicator.adaptive()),
                                                      ),
                                                      errorWidget: (context, url, error) {
                                                        return const Icon(Icons.broken_image, size: 48, color: Colors.grey);
                                                      },
                                                    ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ValueListenableBuilder<Box<int>>(
                                      valueListenable: _favoritesRepo.a_box.listenable(),
                                      builder: (context, box, child) {
                                        final isFavorite = _favoritesRepo.isFavorite(p.id);
                                        return Positioned(
                                          bottom: 4,
                                          left: 4,
                                          child: IconButton(
                                            visualDensity: VisualDensity.compact,
                                            icon: AnimatedSwitcher(
                                              duration: const Duration(milliseconds: 300),
                                              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                                              child: Icon(
                                                isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                                key: ValueKey(isFavorite),
                                                color: isFavorite ? Colors.red : Colors.black26,
                                                size: 24,
                                                shadows: const [BoxShadow(color: Colors.white, blurRadius: 8, spreadRadius: 4)],
                                              ),
                                            ),
                                            onPressed: () => _favoritesRepo.toggle(p),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
