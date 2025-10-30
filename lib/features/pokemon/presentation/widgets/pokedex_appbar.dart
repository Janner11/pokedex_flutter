import 'package:flutter/material.dart';

/// AppBar con look Pokédex
class PokedexAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  const PokedexAppBar({super.key, this.title});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AppBar(
      title: Text(
        title ?? '',
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 18,
          letterSpacing: 0.5,
        ),
      ),
      backgroundColor: cs.primary,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.3),
    );
  }
}