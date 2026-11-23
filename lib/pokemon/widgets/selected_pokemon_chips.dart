import 'package:flutter/material.dart';

class SelectedPokemonChips extends StatelessWidget {
  final String title;
  final List<String> pokemonNames;
  final ValueChanged<String> onDeleted;
  final VoidCallback onClearAll;

  const SelectedPokemonChips({
    super.key,
    required this.title,
    required this.pokemonNames,
    required this.onDeleted,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final titleWithCount = '$title ${pokemonNames.length}마리';

    return Semantics(
      container: true,
      label: titleWithCount,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  titleWithCount,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              TextButton.icon(
                onPressed: onClearAll,
                icon: const Icon(Icons.clear_all),
                label: const Text('전체 해제'),
              ),
            ],
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 96),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  ...pokemonNames.map((pokemonName) {
                    return InputChip(
                      label: Text(pokemonName),
                      deleteIcon: const Icon(Icons.close),
                      deleteButtonTooltipMessage: '$pokemonName 삭제',
                      onDeleted: () => onDeleted(pokemonName),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
