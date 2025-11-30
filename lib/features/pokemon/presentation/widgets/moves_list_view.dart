import 'package:flutter/material.dart';
import '../../domain/models/pokemon.dart';
import '../widgets/type_chip.dart';
import 'package:collection/collection.dart'; // For firstWhereOrNull

class MovesListView extends StatefulWidget {
  final List<Move> moves;
  final int generationId;
  const MovesListView({super.key, required this.moves, required this.generationId});

  @override
  State<MovesListView> createState() => _MovesListViewState();
}

class _MovesListViewState extends State<MovesListView> {
  // Possible filters for learning methods
  final _filters = {
    'Por Nivel': 'level-up',
    'Máquina/MT': 'machine',
    'Tutor': 'tutor',
    'Huevo': 'egg',
  };
  String _selectedFilter = 'level-up';

  // Possible sorting options
  final _sortOptions = {
    'Nivel': 'level',
    'Nombre': 'name',
  };
  String _selectedSort = 'level'; // Default sort option

  // Map generation ID to a relevant version group (game)
  static const Map<int, String> _generationVersionGroup = {
    1: 'red-blue',
    2: 'gold-silver',
    3: 'ruby-sapphire',
    4: 'diamond-pearl',
    5: 'black-white',
    6: 'x-y',
    7: 'sun-moon',
    8: 'sword-shield',
    9: 'scarlet-violet',
  };

  List<String> _availableVersionGroups = [];
  String? _selectedVersionGroup;

  // Pagination
  int _currentPage = 1;
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _populateVersionGroups();
  }

  // Re-run when moves change (e.g. when data loads from network)
  @override
  void didUpdateWidget(MovesListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.moves != oldWidget.moves) {
      _populateVersionGroups();
    }
  }

  void _populateVersionGroups() {
    final allVersionGroups = widget.moves
        .map((m) => m.versionGroup)
        .whereType<String>()
        .toSet()
        .toList();
    allVersionGroups.sort(); // Sort alphabetically for display

    setState(() {
      _availableVersionGroups = allVersionGroups;
      
      // If we already have a selection and it's valid, keep it.
      if (_selectedVersionGroup != null && _availableVersionGroups.contains(_selectedVersionGroup)) {
        return;
      }

      // Otherwise set a default selected version group based on generation
      final defaultForGen = _generationVersionGroup[widget.generationId];
      if (defaultForGen != null && _availableVersionGroups.contains(defaultForGen)) {
         _selectedVersionGroup = defaultForGen;
      } else {
         _selectedVersionGroup = allVersionGroups.firstOrNull;
      }
    });
  }

  void _resetPage() {
    setState(() {
      _currentPage = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // --- ENHANCED FILTERING LOGIC ---
    List<Move> filteredMoves = widget.moves.where((m) {
      bool matchesLearnMethod = m.learnMethod == _selectedFilter;
      bool matchesVersionGroup = true;

      if (_selectedVersionGroup != null) {
        // Special case: Tutor and Egg moves are often shared across games or sparse.
        // If the user explicitly selects a game, we respect it.
        // But typically for Tutor/Egg we might want to show all.
        // However, to keep the UI consistent with the dropdown, we filter by the selected game IF it's level-up/machine.
        // For Tutor/Egg, let's allow seeing all if the user hasn't picked a specific game, OR if they have, show only that game's.
        // BUT, your requirement was "show egg/tutor moves". Often these are missing in specific games.
        // Let's relax the filter for Tutor/Egg: if selected game has no tutor moves, maybe show others?
        // For simplicity and strictness: we filter by selected version group.
        // IF you want to see ALL tutor moves, maybe we should have an "All Games" option?
        // For now, I will stick to: Filter by selected game. This is consistent.
        // CAUTION: If Solrock has no moves in Scarlet-Violet, and that is selected, list is empty.
        // The user must change the dropdown to Ruby-Sapphire to see them.
        // My previous logic auto-selected the correct game.
        
        matchesVersionGroup = m.versionGroup == _selectedVersionGroup;
      }
      return matchesLearnMethod && matchesVersionGroup;
    }).toList();

    // Remove duplicates by name (if same move appears multiple times in same game/method - rare but possible)
    final uniqueMoves = <String, Move>{};
    for (var move in filteredMoves) {
      uniqueMoves[move.name] = move;
    }
    filteredMoves = uniqueMoves.values.toList();

    // --- SORTING LOGIC ---
    if (_selectedSort == 'level' && _selectedFilter == 'level-up') {
      filteredMoves.sort((a, b) => a.level.compareTo(b.level));
    } else if (_selectedSort == 'name') {
      filteredMoves.sort((a, b) => a.name.compareTo(b.name));
    }

    // --- PAGINATION LOGIC ---
    final totalPages = (filteredMoves.length / _pageSize).ceil();
    // Safety check for current page
    if (_currentPage > totalPages && totalPages > 0) _currentPage = 1;
    if (totalPages == 0) _currentPage = 1;

    final paginatedMoves = filteredMoves
        .skip((_currentPage - 1) * _pageSize)
        .take(_pageSize)
        .toList();
    // --------------------------------

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Wrap(
                spacing: 8,
                children: _filters.entries.map((entry) {
                  final isSelected = _selectedFilter == entry.value;
                  return FilterChip(
                    label: Text(entry.key),
                    selected: isSelected,
                    backgroundColor: Colors.grey[200],
                    labelStyle: TextStyle(color: Colors.grey[800]),
                    selectedColor: theme.colorScheme.primary,
                    showCheckmark: false,
                    side: BorderSide(
                      color: isSelected ? Colors.transparent : Colors.grey[400]!,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        _resetPage();
                        setState(() {
                          _selectedFilter = entry.value;
                          // Reset sort to level if level-up is selected
                          if (_selectedFilter == 'level-up') {
                            _selectedSort = 'level';
                          } else {
                            _selectedSort = 'name'; // Default to name for other filters
                          }
                        });
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Filters Row 2: Game and Sort
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              if (_availableVersionGroups.isNotEmpty) ...[
                DropdownButton<String>(
                  value: _availableVersionGroups.contains(_selectedVersionGroup) ? _selectedVersionGroup : null,
                  hint: const Text('Juego'),
                  onChanged: (String? newValue) {
                    _resetPage();
                    setState(() {
                      _selectedVersionGroup = newValue;
                    });
                  },
                  items: _availableVersionGroups.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value.replaceAll('-', ' ').split(' ').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ')),
                    );
                  }).toList(),
                ),
                const SizedBox(width: 16),
              ],
              DropdownButton<String>(
                value: _selectedSort,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    _resetPage();
                    setState(() {
                      _selectedSort = newValue;
                    });
                  }
                },
                items: _sortOptions.entries.map<DropdownMenuItem<String>>((entry) {
                  // Disable 'Nivel' sort if not 'level-up' filter
                  final bool isLevelSortDisabled = entry.value == 'level' && _selectedFilter != 'level-up';
                  return DropdownMenuItem<String>(
                    value: entry.value,
                    enabled: !isLevelSortDisabled,
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        color: isLevelSortDisabled ? Colors.grey : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (paginatedMoves.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Text("No se encontraron movimientos para este filtro."),
            ),
          )
        else
          Column(
            children: [
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: paginatedMoves.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final move = paginatedMoves[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    leading: _selectedFilter == 'level-up' && _selectedSort == 'level'
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
              if (totalPages > 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _currentPage > 1
                          ? () {
                              setState(() {
                                _currentPage--;
                              });
                            }
                          : null,
                    ),
                    Text('Página $_currentPage de $totalPages'),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: _currentPage < totalPages
                          ? () {
                              setState(() {
                                _currentPage++;
                              });
                            }
                          : null,
                    ),
                  ],
                ),
            ],
          ),
      ],
    );
  }
}

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
