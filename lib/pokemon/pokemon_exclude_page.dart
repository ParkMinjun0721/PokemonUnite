import 'package:flutter/material.dart';
import 'package:pokemonbattle/widgets/assignment_summary_box.dart';
import 'package:pokemonbattle/widgets/labeled_progress_indicator.dart';
import '../data/pokemon_data.dart';
import 'pokemon_assignment_page.dart';
import 'widgets/empty_pokemon_search_result.dart';
import 'widgets/selected_pokemon_chips.dart';

class ExcludePokemonPage extends StatefulWidget {
  final List<String> players;
  final List<String> selectedCategories;

  const ExcludePokemonPage({
    super.key,
    required this.players,
    required this.selectedCategories,
  });

  @override
  State<ExcludePokemonPage> createState() => _ExcludePokemonPageState();
}

class _ExcludePokemonPageState extends State<ExcludePokemonPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> excludedPokemon = [];
  String searchQuery = '';

  List<Map<String, String>> get candidatePokemon {
    return pokemonList
        .where((pokemon) =>
            widget.selectedCategories.contains(pokemon['category']))
        .toList();
  }

  int get assignablePokemonCount {
    return candidatePokemon
        .where((pokemon) => !excludedPokemon.contains(pokemon['name']))
        .length;
  }

  bool get canAssign => assignablePokemonCount >= 5;
  bool get hasExcludedPokemon => excludedPokemon.isNotEmpty;
  bool get hasSearchQuery => searchQuery.trim().isNotEmpty;
  double get assignablePokemonProgress => candidatePokemon.isEmpty
      ? 0
      : (assignablePokemonCount / candidatePokemon.length).clamp(0, 1);
  int get visiblePokemonCount => categorizedPokemon.values.fold(
        0,
        (total, pokemon) => total + pokemon.length,
      );
  String get actionLabel =>
      hasExcludedPokemon ? '제외 목록으로 랜덤 배정' : '제외 없이 랜덤 배정';
  String get categorySummary => widget.selectedCategories.join(', ');
  String get assignmentSummary =>
      '적용 포지션 $categorySummary · 제외 ${excludedPokemon.length}마리 · 배정 가능 $assignablePokemonCount마리';
  String get helperText => hasExcludedPokemon
      ? '선택한 포켓몬은 랜덤 배정 후보에서 제외됩니다.'
      : '제외할 포켓몬이 없으면 전체 후보에서 랜덤 배정됩니다.';

  // 포켓몬을 카테고리별로 분류하고 검색어로 필터링
  Map<String, List<String>> get categorizedPokemon {
    final Map<String, List<String>> categories = {
      for (final category in widget.selectedCategories) category: [],
    };

    for (final pokemon in candidatePokemon) {
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

  void clearExcludedPokemon() {
    final previousPokemon = List<String>.from(excludedPokemon);

    setState(() {
      excludedPokemon.clear();
    });

    if (previousPokemon.isEmpty) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('제외한 포켓몬을 모두 해제했습니다.'),
          action: SnackBarAction(
            label: '되돌리기',
            onPressed: () {
              setState(() {
                excludedPokemon = previousPokemon;
              });
            },
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('제외할 포켓몬 선택')),
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
                  '제외 ${excludedPokemon.length}마리 · 배정 가능 $assignablePokemonCount마리',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  helperText,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                LabeledProgressIndicator(
                  value: assignablePokemonProgress,
                  semanticLabel: '배정 가능 포켓몬 후보 진행률',
                  semanticValue:
                      '$assignablePokemonCount/${candidatePokemon.length}마리',
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
                if (hasExcludedPokemon)
                  SelectedPokemonChips(
                    title: '제외한 포켓몬',
                    pokemonNames: excludedPokemon,
                    onDeleted: (pokemonName) {
                      setState(() {
                        excludedPokemon.remove(pokemonName);
                      });
                    },
                    onClearAll: clearExcludedPokemon,
                  ),
                if (hasExcludedPokemon) const SizedBox(height: 8),
                if (!hasExcludedPokemon && !hasSearchQuery)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '포켓몬을 검색하거나 포지션을 열어 제외할 후보를 선택하세요.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                if (!hasExcludedPokemon && !hasSearchQuery)
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
                              key:
                                  ValueKey('exclude-${entry.key}-$searchQuery'),
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
                                            selected: excludedPokemon.contains(
                                              pokemonName,
                                            ),
                                            onSelected: (bool selected) {
                                              setState(() {
                                                if (selected) {
                                                  excludedPokemon.add(
                                                    pokemonName,
                                                  );
                                                } else {
                                                  excludedPokemon.remove(
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
                if (!canAssign)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      '배정 가능한 포켓몬이 5마리 이상 남아야 합니다.',
                      style: TextStyle(color: Colors.redAccent),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 8),
                AssignmentSummaryBox(
                  semanticLabel: '제외 포켓몬 배정 조건',
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
                                  selectedCategories: widget.selectedCategories,
                                  excludedPokemon: excludedPokemon,
                                ),
                              ),
                            );
                          }
                        : null,
                    icon: const Icon(Icons.casino),
                    label: Text(actionLabel),
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
