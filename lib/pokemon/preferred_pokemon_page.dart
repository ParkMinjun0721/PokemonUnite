import 'package:flutter/material.dart';
import '../data/pokemon_data.dart';
import '../widgets/match_page.dart';
import 'pokemon_assignment_page.dart';
import 'pokemon_picker.dart';

class PreferredPokemonPage extends StatefulWidget {
  const PreferredPokemonPage({
    super.key,
    required this.players,
    this.initialSelection = const {},
    this.onSelectionChanged,
  });
  final List<String> players;
  final Set<String> initialSelection;
  final ValueChanged<Set<String>>? onSelectionChanged;

  @override
  State<PreferredPokemonPage> createState() => _PreferredPokemonPageState();
}

class _PreferredPokemonPageState extends State<PreferredPokemonPage> {
  late Set<String> selected = widget.initialSelection;

  @override
  Widget build(BuildContext context) {
    return MatchPage(
      title: '선호 포켓몬 선택',
      action: FilledButton(
        onPressed: selected.length < 5
            ? null
            : () {
                FocusScope.of(context).unfocus();
                Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => PokemonAssignmentPage(
                      players: widget.players,
                      selectedCategories: const [],
                      preferredPokemon: selected.toList()),
                ));
              },
        child: Text('선택 ${selected.length}마리 · 배정하기'),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('두 팀이 사용할 포켓몬을 최소 5마리 선택하세요.',
            style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 16),
        PokemonPicker(
          candidates: pokemonList,
          listLabel: '선택 목록',
          selected: selected,
          onChanged: (names) {
            setState(() => selected = names);
            widget.onSelectionChanged?.call(names);
          },
        ),
      ]),
    );
  }
}
