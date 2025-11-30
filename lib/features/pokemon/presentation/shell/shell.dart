import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.catching_pokemon),
            label: 'Pokédex',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border_rounded),
            activeIcon: Icon(Icons.favorite_rounded),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology_alt_outlined),
            activeIcon: Icon(Icons.psychology_alt),
            label: 'Trivia',
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
