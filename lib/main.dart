import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/graphql_client.dart';
import 'core/theming.dart';
import 'core/theme_provider.dart'; // 🔹 Importar ThemeProvider
import 'features/pokemon/presentation/favorites/favorites_screen.dart';
import 'features/pokemon/presentation/list/pokemon_list_screen.dart';
import 'features/pokemon/presentation/detail/pokemon_detail_screen.dart';
import 'features/pokemon/presentation/shell/shell.dart';
import 'features/trivia/presentation/screens/trivia_screen.dart';
import 'features/pokemon/presentation/map/pokemon_map_screen.dart';
import 'features/trivia/presentation/screens/ranking_screen.dart';
import 'features/trivia/presentation/screens/achievements_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<int>('favorites');
  await Hive.openBox<Map>('favorite_details');
  await Hive.openBox<Map>('trivia_scores');
  await Hive.openBox<bool>('trivia_achievements');
  await Hive.openBox('settings'); // 🔹 Caja para configuración (tema)
  
  runApp(const App());
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
// 🔹 Instancia global del ThemeProvider (simple y efectiva)
final themeProvider = ThemeProvider();

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final client = buildGqlClient();

    final router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      redirect: (context, state) async {
        final prefs = await SharedPreferences.getInstance();
        final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
        
        // If onboarding is not completed and we are not already on the onboarding screen
        if (!onboardingCompleted && state.matchedLocation != '/onboarding') {
          return '/onboarding';
        }
        
        // If onboarding is completed and we are trying to access onboarding screen
        if (onboardingCompleted && state.matchedLocation == '/onboarding') {
          return '/';
        }
        
        return null;
      },
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/pokemon/:id',
          builder: (context, state) => PokemonDetailScreen(
            id: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/pokemon_map/:name/:id',
          builder: (context, state) => PokemonMapScreen(
            pokemonName: state.pathParameters['name']!,
            pokemonId: int.parse(state.pathParameters['id']!),
          ),
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
                  builder: (context, state) {
                    final refreshKey = state.uri.queryParameters['refresh'] ?? 'default';
                    return PokemonListScreen(key: ValueKey(refreshKey));
                  },
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
                  routes: [
                    GoRoute(
                      path: 'ranking',
                      builder: (context, state) => const RankingScreen(),
                    ),
                    GoRoute(
                      path: 'achievements',
                      builder: (context, state) => const AchievementsScreen(),
                    ),
                  ],
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
      // 🔹 Escuchar cambios en el tema y el idioma
      child: ListenableBuilder(
        listenable: themeProvider,
        builder: (context, _) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            // 🔹 Temas dinámicos
            theme: appThemeLight(),
            darkTheme: appThemeDark(),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            // ------------------
            routerConfig: router,
            locale: themeProvider.locale, // 🔹 Usar el idioma seleccionado
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('es', ''),
            ],
            builder: (context, child) {
              return ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  scrollbars: false,
                  overscroll: false,
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
