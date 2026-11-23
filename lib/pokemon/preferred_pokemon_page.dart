import 'package:flutter/material.dart';
import '../data/pokemon_data.dart';
import '../widgets/match_page.dart';
import 'pokemon_assignment_page.dart';

class PreferredPokemonPage extends StatefulWidget {
  const PreferredPokemonPage({super.key, required this.players});
  final List<String> players;

  @override
  State<PreferredPokemonPage> createState() => _PreferredPokemonPageState();
}

class _PreferredPokemonPageState extends State<PreferredPokemonPage> {
  final selected = <String>{};
  final search = TextEditingController();
  bool showSelected = false;

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  Widget _options(Iterable<Map<String, String>> options) {
    return Wrap(spacing: 8, runSpacing: 4, children: [
      for (final pokemon in options)
        FilterChip(
          label: Text(pokemon['name']!),
          selected: selected.contains(pokemon['name']),
          onSelected: (enabled) => setState(() {
            final name = pokemon['name']!;
            if (enabled) {
              selected.add(name);
            } else {
              selected.remove(name);
            }
          }),
        ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final query = search.text.trim().toLowerCase();
    final matches =
        pokemonList.where((p) => p['name']!.toLowerCase().contains(query));
    final roles = pokemonList.map((p) => p['category']!).toSet();
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
        TextField(
          controller: search,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: '포켓몬 검색',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: search.text.isEmpty
                ? null
                : IconButton(
                    tooltip: '검색어 지우기',
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(search.clear),
                  ),
          ),
        ),
        Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: selected.isEmpty && !showSelected
                  ? null
                  : () => setState(() => showSelected = !showSelected),
              icon: Icon(showSelected ? Icons.expand_less : Icons.expand_more),
              label: Text('선택 목록 (${selected.length})'),
            )),
        if (showSelected)
          Wrap(spacing: 8, children: [
            for (final name in selected)
              InputChip(
                  label: Text(name),
                  deleteButtonTooltipMessage: '$name 선택 해제',
                  onDeleted: () => setState(() => selected.remove(name))),
          ]),
        if (query.isNotEmpty) ...[
          if (matches.isEmpty)
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('검색 결과가 없습니다. 다른 이름을 입력해 보세요.'))
          else
            _options(matches),
        ] else
          for (final role in roles)
            ExpansionTile(
              key: PageStorageKey(role),
              title: Text(role),
              expandedAlignment: Alignment.centerLeft,
              childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
              children: [
                _options(pokemonList.where((p) => p['category'] == role))
              ],
            ),
      ]),
    );
  }
}
