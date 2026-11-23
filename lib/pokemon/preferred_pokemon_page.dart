import 'package:flutter/material.dart';
import 'package:pokemonbattle/widgets/assignment_summary_box.dart';
import 'package:pokemonbattle/widgets/labeled_progress_indicator.dart';
import 'pokemon_assignment_page.dart';
import '../data/pokemon_data.dart';
import 'widgets/empty_pokemon_search_result.dart';
import 'widgets/selected_pokemon_chips.dart';

class PreferredPokemonPage extends StatefulWidget {
  final List<String> players;

  const PreferredPokemonPage({super.key, required this.players});

  @override
  State<PreferredPokemonPage> createState() => _PreferredPokemonPageState();
}

class _PreferredPokemonPageState extends State<PreferredPokemonPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> selectedPokemon = [];
  String searchQuery = '';

  bool get canAssign => selectedPokemon.length >= 5;
  bool get hasSelectedPokemon => selectedPokemon.isNotEmpty;
  bool get hasSearchQuery => searchQuery.trim().isNotEmpty;
  int get visiblePokemonCount => categorizedPokemon.values.fold(
        0,
        (total, pokemon) => total + pokemon.length,
      );
  int get remainingRequiredPokemon => (5 - selectedPokemon.length).clamp(0, 5);
  double get selectionProgress => (selectedPokemon.length / 5).clamp(0, 1);
  String get assignmentSummary => hasSelectedPokemon
      ? '배정 후보 ${selectedPokemon.length}마리 · 선택한 포켓몬만 사용'
      : '배정 후보 없음 · 최소 5마리 선택 필요';
  String get helperText => canAssign
      ? '선택한 포켓몬 후보 안에서 랜덤 배정됩니다.'
      : '선호 포켓몬을 $remainingRequiredPokemon마리 더 선택해주세요.';

  // 포켓몬을 카테고리별로 분류
  Map<String, List<String>> get categorizedPokemon {
    Map<String, List<String>> categories = {
      '어택형': [],
      '밸런스형': [],
      '스피드형': [],
      '디펜스형': [],
      '서포트형': [],
    };

    for (var pokemon in pokemonList) {
      String category = pokemon['category']!;
      String name = pokemon['name']!;
      if (name.toLowerCase().contains(searchQuery.toLowerCase())) {
        categories[category]?.add(name);
      }
    }

    return categories;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void clearSearchQuery() {
    _searchController.clear();
    setState(() {
      searchQuery = '';
    });
  }

  void clearSelectedPokemon() {
    final previousPokemon = List<String>.from(selectedPokemon);

    setState(() {
      selectedPokemon.clear();
    });

    if (previousPokemon.isEmpty) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('선택한 포켓몬을 모두 해제했습니다.'),
          action: SnackBarAction(
            label: '되돌리기',
            onPressed: () {
              setState(() {
                selectedPokemon = previousPokemon;
              });
            },
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('선호 포켓몬 선택')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 400, // 화면 크기를 400px로 제한
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  '선택 ${selectedPokemon.length}마리',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  helperText,
                  style: canAssign
                      ? null
                      : const TextStyle(color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                LabeledProgressIndicator(
                  value: selectionProgress,
                  semanticLabel: '선호 포켓몬 선택 진행률',
                  semanticValue: '${selectedPokemon.length}/5마리',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: '포켓몬 검색',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: hasSearchQuery
                        ? IconButton(
                            tooltip: '검색어 지우기',
                            onPressed: clearSearchQuery,
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                if (hasSearchQuery)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '검색 결과 $visiblePokemonCount마리',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                if (hasSearchQuery) const SizedBox(height: 8),
                if (hasSelectedPokemon)
                  SelectedPokemonChips(
                    title: '선택한 포켓몬',
                    pokemonNames: selectedPokemon,
                    onDeleted: (pokemonName) {
                      setState(() {
                        selectedPokemon.remove(pokemonName);
                      });
                    },
                    onClearAll: clearSelectedPokemon,
                  ),
                if (hasSelectedPokemon) const SizedBox(height: 8),
                if (!hasSelectedPokemon && !hasSearchQuery)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '포켓몬을 검색하거나 포지션을 열어 후보를 선택하세요.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                if (!hasSelectedPokemon && !hasSearchQuery)
                  const SizedBox(height: 8),
                const SizedBox(height: 8),
                Expanded(
                  child: visiblePokemonCount == 0
                      ? EmptyPokemonSearchResult(
                          message: '"$searchQuery" 검색 결과가 없습니다.',
                          onClear: clearSearchQuery,
                        )
                      : ListView(
                          children: categorizedPokemon.entries.map((entry) {
                            if (entry.value.isEmpty) {
                              return const SizedBox();
                            }
                            return ExpansionTile(
                              key: ValueKey(
                                'preferred-${entry.key}-$searchQuery',
                              ),
                              initiallyExpanded: hasSearchQuery,
                              title: Text(
                                '${entry.key} ${entry.value.length}마리',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 4.0,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: [
                                        ...entry.value.map((pokemonName) {
                                          return FilterChip(
                                            label: Text(pokemonName),
                                            selected: selectedPokemon.contains(
                                              pokemonName,
                                            ),
                                            onSelected: (bool selected) {
                                              setState(() {
                                                if (selected) {
                                                  selectedPokemon.add(
                                                    pokemonName,
                                                  );
                                                } else {
                                                  selectedPokemon.remove(
                                                    pokemonName,
                                                  );
                                                }
                                              });
                                            },
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                ),
                const SizedBox(height: 8),
                AssignmentSummaryBox(
                  semanticLabel: '선호 포켓몬 배정 조건',
                  summary: assignmentSummary,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: canAssign
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PokemonAssignmentPage(
                                  players: widget.players,
                                  selectedCategories: const [], // 카테고리 없음
                                  preferredPokemon:
                                      selectedPokemon, // 선택된 포켓몬 전달
                                ),
                              ),
                            );
                          }
                        : null,
                    icon: const Icon(Icons.star),
                    label: const Text('선호 포켓몬으로 배정'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
