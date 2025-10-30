import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'core/graphql_client.dart';
import 'core/theming.dart';
import 'features/pokemon/presentation/list/pokemon_list_screen.dart';
import 'features/pokemon/presentation/detail/pokemon_detail_screen.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final client = buildGqlClient();

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const PokemonListScreen(),
        ),
        GoRoute(
          path: '/pokemon/:id',
          builder: (_, state) => PokemonDetailScreen(
            id: state.pathParameters['id']!,
          ),
        ),
      ],
      // Transiciones personalizadas
      observers: [
        HeroController(),
      ],
    );

    return GraphQLProvider(
      client: client,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: appTheme(),
        routerConfig: router,
        // Mejoras adicionales de rendimiento y UX
        builder: (context, child) {
          return ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              scrollbars: false,
              overscroll: false,
            ),
            child: child!,
          );
        },
      ),
    );
  }
}