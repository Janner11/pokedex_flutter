import 'package:flutter/material.dart';
import '../../domain/models/pokemon.dart';
import '../widgets/type_chip.dart';

class MovesListView extends StatefulWidget {
  final List<Move> moves;
  const MovesListView({super.key, required this.moves});

  @override
  State<MovesListView> createState() => _MovesListViewState();
}

class _MovesListViewState extends State<MovesListView> {
  // Possible filters
  final _filters = {
    'Por Nivel': 'level-up',
    'Máquina/MT': 'machine',
    'Tutor': 'tutor',
    'Huevo': 'egg',
  };
  String _selectedFilter = 'level-up';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final filteredMoves = widget.moves.where((m) => m.learnMethod == _selectedFilter).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Wrap(
            spacing: 8,
            children: _filters.entries.map((entry) {
              final isSelected = _selectedFilter == entry.value;
              return FilterChip(
                label: Text(entry.key),
                selected: isSelected,
                // --- STYLE FIX ---
                backgroundColor: Colors.grey[200],
                labelStyle: TextStyle(color: Colors.grey[800]),
                selectedColor: theme.colorScheme.primary,
                showCheckmark: false,
                side: BorderSide(
                  color: isSelected ? Colors.transparent : Colors.grey[400]!,
                ),
                // -----------------
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedFilter = entry.value;
                    });
                  }
                },
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),

        // Moves List
        if (filteredMoves.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Text("No se encontraron movimientos para este filtro."),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredMoves.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final move = filteredMoves[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                // Level for 'level-up' moves
                leading: _selectedFilter == 'level-up'
                    ? Text(
                        'Nvl. ${move.level}',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      )
                    : null,
                title: Text(
                  move.name.replaceAll('-', ' ').split(' ').map((w) => w[0].toUpperCase() + w.substring(1)).join(' '),
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: TypeChip(type: move.type, isSmall: true),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _StatPill(label: 'PWR', value: move.power?.toString() ?? '--'),
                    const SizedBox(width: 8),
                    _StatPill(label: 'PP', value: move.pp?.toString() ?? '--'),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

// A small pill-shaped widget to display a stat (like PWR or PP)
class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(
            '$label ',
            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey[700]),
          ),
          Text(value, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
