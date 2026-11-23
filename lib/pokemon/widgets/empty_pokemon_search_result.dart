import 'package:flutter/material.dart';

class EmptyPokemonSearchResult extends StatelessWidget {
  final String message;
  final VoidCallback onClear;

  const EmptyPokemonSearchResult({
    super.key,
    required this.message,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: 40,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.clear),
            label: const Text('검색어 지우기'),
          ),
        ],
      ),
    );
  }
}
