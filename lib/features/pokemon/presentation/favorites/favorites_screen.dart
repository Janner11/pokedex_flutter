import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/favorites_repository.dart';
import '../../domain/models/pokemon.dart';
import '../widgets/error_view.dart';
import '../widgets/pokedex_appbar.dart';

// Query to fetch multiple pokemon by their IDs
const getFavoritePokemons = r"""
  query GetFavoritePokemons($ids: [Int!]) {
    pokemon_v2_pokemon(where: {id: {_in: $ids}}) {
      id
      name
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

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _favoritesRepo = FavoritesRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PokedexAppBar(title: 'Favoritos'),
      body: ValueListenableBuilder<Box<int>>(
        valueListenable: _favoritesRepo.a_box.listenable(),
        builder: (context, box, child) {
          final favoriteIds = box.values.toList();

          if (favoriteIds.isEmpty) {
            return const Center(
              child: Text('Aún no has añadido ningún Pokémon a favoritos.'),
            );
          }

          return Query(
            options: QueryOptions(
              document: gql(getFavoritePokemons),
              variables: {'ids': favoriteIds},
            ),
            builder: (QueryResult result, {refetch, fetchMore}) {
              if (result.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (result.hasException) {
                return ErrorView(onRetry: () => refetch!());
              }

              final List<Pokemon> pokemonList = (result.data?['pokemon_v2_pokemon'] as List)
                  .map((p) => Pokemon.fromMap(p))
                  .toList();

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: pokemonList.length,
                itemBuilder: (context, index) {
                  final pokemon = pokemonList[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: Image.network(pokemon.imageUrl, width: 50, height: 50),
                      title: Text(pokemon.name[0].toUpperCase() + pokemon.name.substring(1)),
                      subtitle: Text('#${pokemon.id.toString().padLeft(4, '0')}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                        onPressed: () => _favoritesRepo.remove(pokemon.id),
                      ),
                      onTap: () => context.push('/pokemon/${pokemon.id}'), // <-- FIX: Use push instead of go
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
