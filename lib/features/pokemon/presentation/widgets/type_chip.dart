import 'package:flutter/material.dart';
import '../../../pokemon/data/type_colors.dart';

class TypeChip extends StatelessWidget {
  final String type;
  const TypeChip({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final c = typeColor(type, Theme.of(context).colorScheme.secondary);
    return Container(
      decoration: BoxDecoration(
        color: c.withOpacity(.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withOpacity(.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: c.withOpacity(.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 11,
          color: c.withOpacity(.9),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}