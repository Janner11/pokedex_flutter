import 'package:flutter/material.dart';
import '../../../pokemon/data/type_colors.dart';

class TypeChip extends StatelessWidget {
  final String type;
  final bool isSmall;

  const TypeChip({super.key, required this.type, this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    final c = typeColor(type, Theme.of(context).colorScheme.secondary);

    // Conditionally set padding and font size based on the 'isSmall' flag.
    final padding = isSmall
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 3)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 5);
    final fontSize = isSmall ? 10.0 : 11.0;

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
      padding: padding,
      child: Text(
        type.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: fontSize,
          color: c.withOpacity(.9),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
