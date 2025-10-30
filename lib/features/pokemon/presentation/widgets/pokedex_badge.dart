import 'package:flutter/material.dart';

/// Badge de ID (#0001) al estilo “placa” discreta
class PokedexBadge extends StatelessWidget {
  final int id;
  const PokedexBadge({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final text = '#${id.toString()}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: ShapeDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(.10),
        shape: StadiumBorder(side: BorderSide(color: Colors.black.withOpacity(.05))),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontFeatures: const [FontFeature.tabularFigures()],
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
