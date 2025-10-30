import 'package:flutter/material.dart';

/// AppBar con look Pokédex (primario rojo, título centrado)
class PokedexAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  const PokedexAppBar({super.key, this.title});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AppBar(
      title: Text(title ?? '', style: const TextStyle(fontWeight: FontWeight.w900)),
      backgroundColor: cs.primary,
      foregroundColor: Colors.white,
      centerTitle: true,
    );
  }
}
