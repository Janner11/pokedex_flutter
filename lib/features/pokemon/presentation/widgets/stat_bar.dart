import 'package:flutter/material.dart';

class StatBar extends StatelessWidget {
  final String name;
  final int value;
  const StatBar({super.key, required this.name, required this.value});

  String get formattedName {
    switch (name) {
      case 'hp': return 'HP';
      case 'attack': return 'ATK';
      case 'defense': return 'DEF';
      case 'special-attack': return 'SP. ATK';
      case 'special-defense': return 'SP. DEF';
      case 'speed': return 'SPD';
      default: return name.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0, 150) / 150.0;
    final cs = Theme.of(context).colorScheme;
    final color = v > 0.7 ? Colors.green[600]! :
    v > 0.4 ? Colors.orange[500]! :
    Colors.red[500]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              formattedName,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.grey[700],
              ),
            ),
            Text(
              value.toString(),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 10,
            decoration: BoxDecoration(
              color: cs.secondary.withOpacity(.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: (v * 100).round(),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.8)],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 100 - (v * 100).round(),
                  child: const SizedBox(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}