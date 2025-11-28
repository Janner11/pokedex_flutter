import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/graphql_client.dart';
import 'core/theming.dart';
import 'features/pokemon/presentation/favorites/favorites_screen.dart';
import 'features/pokemon/presentation/list/pokemon_list_screen.dart';
import 'features/pokemon/presentation/detail/pokemon_detail_screen.dart';
import 'features/pokemon/presentation/shell/shell.dart';
import 'features/trivia/presentation/screens/achievements_screen.dart';
import 'features/trivia/presentation/screens/ranking_screen.dart';
import 'features/trivia/presentation/screens/trivia_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<int>('favorites');
  runApp(const App());
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final client = buildGqlClient();

    final router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/pokemon/:id',
          builder: (context, state) => PokemonDetailScreen(
            id: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/trivia/ranking',
          builder: (context, state) => const RankingScreen(),
        ),
        GoRoute(
          path: '/trivia/achievements',
          builder: (context, state) => const AchievementsScreen(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return Shell(child: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const PokemonListScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/favorites',
                  builder: (context, state) => const FavoritesScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/trivia',
                  builder: (context, state) => const TriviaScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
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
