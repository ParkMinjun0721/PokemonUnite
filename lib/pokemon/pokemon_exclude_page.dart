import 'package:flutter/material.dart';
import '../widgets/match_page.dart';
import 'pokemon_assignment_logic.dart';
import 'pokemon_assignment_page.dart';
import 'pokemon_picker.dart';

class ExcludePokemonPage extends StatefulWidget {
  const ExcludePokemonPage(
      {super.key, required this.players, required this.selectedCategories});

  final List<String> players;
  final List<String> selectedCategories;

  @override
  State<ExcludePokemonPage> createState() => _ExcludePokemonPageState();
}

class _ExcludePokemonPageState extends State<ExcludePokemonPage> {
  final excluded = <String>{};
  late final candidates = PokemonAssignmentLogic()
      .getFilteredPokemonList(widget.selectedCategories);

  @override
  Widget build(BuildContext context) {
    final remaining = candidates.length - excluded.length;
    return MatchPage(
      title: '제외할 포켓몬 선택',
      action: FilledButton(
        onPressed: remaining < 5
            ? null
            : () {
                FocusScope.of(context).unfocus();
                Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => PokemonAssignmentPage(
                    players: widget.players,
                    selectedCategories: widget.selectedCategories,
                    excludedPokemon: excluded.toList(),
                  ),
                ));
              },
        child: Text(excluded.isEmpty ? '제외 없이 랜덤 배정' : '제외 목록으로 랜덤 배정'),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('제외 ${excluded.length}마리 · 배정 가능 $remaining마리',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        const Text('배정에서 뺄 포켓몬을 선택하세요. 후보가 최소 5마리 남아야 합니다.'),
        const SizedBox(height: 16),
        PokemonPicker(
          candidates: candidates,
          listLabel: '제외 목록',
          selected: excluded,
          onClear: () => setState(excluded.clear),
          onChanged: (name, enabled) => setState(() {
            if (enabled) {
              excluded.add(name);
            } else {
              excluded.remove(name);
            }
          }),
        ),
      ]),
    );
  }
}
