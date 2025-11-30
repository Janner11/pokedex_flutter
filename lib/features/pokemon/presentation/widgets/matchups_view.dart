import 'package:flutter/material.dart';
import '../../data/type_matchups.dart';
import '../widgets/type_chip.dart';

class MatchupsView extends StatelessWidget {
  final List<String> types;

  const MatchupsView({super.key, required this.types});

  @override
  Widget build(BuildContext context) {
    final effectiveness = TypeMatchups.getDefensiveEffectiveness(types);
    
    final weak4x = <String>[];
    final weak2x = <String>[];
    final resist05x = <String>[];
    final resist025x = <String>[];
    final immune0x = <String>[];

    effectiveness.forEach((type, multiplier) {
      if (multiplier == 4.0) weak4x.add(type);
      else if (multiplier == 2.0) weak2x.add(type);
      else if (multiplier == 0.5) resist05x.add(type);
      else if (multiplier == 0.25) resist025x.add(type);
      else if (multiplier == 0.0) immune0x.add(type);
    });

    if (effectiveness.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (weak4x.isNotEmpty) _buildRow(context, "Debilidad Extrema (x4)", weak4x, Colors.black),
        if (weak2x.isNotEmpty) _buildRow(context, "Debilidad (x2)", weak2x, Colors.black),
        if (resist05x.isNotEmpty) _buildRow(context, "Resistencia (x0.5)", resist05x, Colors.black),
        if (resist025x.isNotEmpty) _buildRow(context, "Resistencia Extrema (x0.25)", resist025x, Colors.black),
        if (immune0x.isNotEmpty) _buildRow(context, "Inmunidad (x0)", immune0x, Colors.black),
      ],
    );
  }

  Widget _buildRow(BuildContext context, String label, List<String> types, Color? labelColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label, 
            style: TextStyle(
              fontWeight: FontWeight.w700, 
              color: labelColor ?? Colors.grey[800], // Use specific color for emphasis or default dark
              fontSize: 13
            )
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: types.map((t) => TypeChip(type: t, isSmall: true)).toList(),
          ),
        ],
      ),
    );
  }
}
