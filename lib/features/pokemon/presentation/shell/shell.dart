import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';

class Shell extends StatelessWidget {
  final Widget child;
  const Shell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.catching_pokemon),
            label: AppLocalizations.of(context).pokedex,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite_border_rounded),
            activeIcon: const Icon(Icons.favorite_rounded),
            label: AppLocalizations.of(context).favorites,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.psychology_alt_outlined),
            activeIcon: const Icon(Icons.psychology_alt),
            label: AppLocalizations.of(context).trivia,
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/favorites')) {
      return 1;
    }
    if (location.startsWith('/trivia')) {
      return 2;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 1:
        context.go('/favorites');
        break;
      case 2:
        context.go('/trivia');
        break;
      case 0:
      default:
        // If we are already on the home tab (index 0), force a reload
        if (_calculateSelectedIndex(context) == 0) {
          // Navigate to root with a unique refresh parameter to force a rebuild
          context.go('/?refresh=${DateTime.now().millisecondsSinceEpoch}');
        } else {
          // Normal navigation to home
          context.go('/');
        }
        break;
    }
  }
}
