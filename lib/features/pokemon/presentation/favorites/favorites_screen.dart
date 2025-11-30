import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/favorites_repository.dart';
import '../../domain/models/pokemon.dart';
import '../widgets/pokedex_appbar.dart';

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
      body: ValueListenableBuilder<Box<Map>>(
        valueListenable: _favoritesRepo.details_box.listenable(),
        builder: (context, box, child) {
          final favoriteDetails = box.values.toList();

          if (favoriteDetails.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Aún no has añadido ningún Pokémon a favoritos.\n¡Explora la Pokédex para añadir algunos!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            );
          }

          final List<Pokemon> pokemonList = favoriteDetails.map((data) {
            return Pokemon.fromMap(Map<String, dynamic>.from(data));
          }).toList();

          pokemonList.sort((a, b) => a.id.compareTo(b.id));

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: pokemonList.length,
            itemBuilder: (context, index) {
              final pokemon = pokemonList[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: SizedBox(
                    width: 50,
                    height: 50,
                    // --- HYBRID IMAGE WIDGET FOR FAVORITES ---
                    child: pokemon.imageBase64 != null
                        ? Image.memory(
                            base64Decode(pokemon.imageBase64!),
                            fit: BoxFit.contain,
                          )
                        : CachedNetworkImage(
                            imageUrl: pokemon.imageUrl,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(strokeWidth: 2)),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.broken_image, color: Colors.grey),
                          ),
                  ),
                  title: Text(
                    pokemon.name[0].toUpperCase() + pokemon.name.substring(1),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('#${pokemon.id.toString().padLeft(4, '0')}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                    onPressed: () => _favoritesRepo.remove(pokemon.id),
                  ),
                  onTap: () => context.push('/pokemon/${pokemon.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
