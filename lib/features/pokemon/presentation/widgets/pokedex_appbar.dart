import 'package:flutter/material.dart';

/// AppBar con look Pokédex.
/// Automáticamente mostrará un botón de "atrás" en las pantallas internas.
class PokedexAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  const PokedexAppBar({super.key, this.title, this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AppBar(
      // La propiedad `automaticallyImplyLeading` (que es `true` por defecto)
      // se encarga de añadir el botón de "atrás" cuando es posible.
      title: Text(
        title ?? '',
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 18,
          letterSpacing: 0.5,
        ),
      ),
      backgroundColor: cs.primary,
      foregroundColor: cs.onPrimary,
      centerTitle: true,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.3),
      actions: actions,
    );
  }
}
