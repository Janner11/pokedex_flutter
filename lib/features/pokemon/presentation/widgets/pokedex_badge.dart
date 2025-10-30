import 'package:flutter/material.dart';

/// Badge de ID (#0001) al estilo “placa”
class PokedexBadge extends StatelessWidget {
  final int id;
  const PokedexBadge({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final text = '#${id.toString().padLeft(4, '0')}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: ShapeDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(.12),
        shape: StadiumBorder(
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary.withOpacity(.2),
            width: 1.5,
          ),
        ),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontFeatures: const [FontFeature.tabularFigures()],
          fontWeight: FontWeight.w800,
          color: Theme.of(context).colorScheme.primary.withOpacity(.8),
        ),
      ),
    );
  }
}