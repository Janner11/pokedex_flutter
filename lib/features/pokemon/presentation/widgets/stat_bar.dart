import 'package:flutter/material.dart';

class StatBar extends StatelessWidget {
  final String name;
  final int value;
  const StatBar({super.key, required this.name, required this.value});

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0, 150) / 150.0;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name.toUpperCase(), style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: v,
            minHeight: 8,
            backgroundColor: cs.secondary.withOpacity(.15),
            color: cs.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text("$value", style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
