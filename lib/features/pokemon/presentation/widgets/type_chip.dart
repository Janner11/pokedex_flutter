import 'package:flutter/material.dart';
import '../../../pokemon/data/type_colors.dart';

class TypeChip extends StatelessWidget {
  final String type;
  const TypeChip({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final c = typeColor(type, Theme.of(context).colorScheme.secondary);
    return Chip(
      label: Text(type.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w700)),
      backgroundColor: c.withOpacity(.15),
      side: BorderSide(color: c.withOpacity(.35)),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
