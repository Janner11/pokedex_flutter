import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

const getFilterData = r"""
  query GetFilterData {
    pokemon_v2_type {
      name
    }
    pokemon_v2_generation {
      id
      name
    }
  }
"""
;

class FilterDialog extends StatefulWidget {
  final String? selectedType;
  final int? selectedGeneration;
  final String sortBy;
  final bool sortAscending;

  const FilterDialog({
    super.key,
    this.selectedType,
    this.selectedGeneration,
    required this.sortBy,
    required this.sortAscending,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  String? _selectedType;
  int? _selectedGeneration;
  String _sortBy = 'id';
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.selectedType;
    _selectedGeneration = widget.selectedGeneration;
    _sortBy = widget.sortBy;
    _sortAscending = widget.sortAscending;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter and Sort'),
      content: Query(
        options: QueryOptions(document: gql(getFilterData)),
        builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final types = (result.data?['pokemon_v2_type'] as List? ?? []).map((t) => t['name'] as String).toList();
          final generations = (result.data?['pokemon_v2_generation'] as List? ?? []).map((g) => g as Map).toList();

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Type'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All')),
                  ...types.map((t) => DropdownMenuItem(value: t, child: Text(t))),
                ],
                onChanged: (value) => setState(() => _selectedType = value),
              ),
              DropdownButtonFormField<int>(
                value: _selectedGeneration,
                decoration: const InputDecoration(labelText: 'Generation'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All')),
                  ...generations.map((g) => DropdownMenuItem(value: g['id'] as int, child: Text(g['name'] as String))),
                ],
                onChanged: (value) => setState(() => _selectedGeneration = value),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Sort by:'),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _sortBy,
                    items: const [
                      DropdownMenuItem(value: 'id', child: Text('ID')),
                      DropdownMenuItem(value: 'name', child: Text('Name')),
                    ],
                    onChanged: (value) => setState(() => _sortBy = value!),
                  ),
                  IconButton(
                    icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
                    onPressed: () => setState(() => _sortAscending = !_sortAscending),
                  ),
                ],
              ),
            ],
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop({
              'type': _selectedType,
              'generation': _selectedGeneration,
              'sortBy': _sortBy,
              'sortAscending': _sortAscending,
            });
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
