import 'package:flutter/material.dart';
import 'package:pokemonbattle/widgets/app_action_tile.dart';
import 'package:pokemonbattle/widgets/labeled_progress_indicator.dart';
import '../data/pokemon_data.dart';
import 'pokemon_assignment_page.dart';
import 'pokemon_exclude_page.dart';
import 'preferred_pokemon_page.dart';

class PokemonCategoryPage extends StatefulWidget {
  final List<String> players;

  const PokemonCategoryPage({super.key, required this.players});

  @override
  State<PokemonCategoryPage> createState() => _PokemonCategoryPageState();
}

class _PokemonCategoryPageState extends State<PokemonCategoryPage> {
  Map<String, bool> categories = {
    '어택형': false,
    '밸런스형': false,
    '스피드형': false,
    '디펜스형': false,
    '서포트형': false,
  };

  int get _selectedCategoryCount =>
      categories.values.where((isSelected) => isSelected).length;

  bool get _hasSelectedCategories => _selectedCategoryCount > 0;

  String get _selectionSummary => _hasSelectedCategories
      ? '선택 $_selectedCategoryCount개'
      : '선택 없음 · 전체 포지션 사용';

  String get _randomAssignLabel =>
      _hasSelectedCategories ? '선택된 카테고리에서 랜덤 배정' : '전체 카테고리에서 랜덤 배정';

  String get _candidateSummary => _hasSelectedCategories
      ? '랜덤 후보 $_candidatePokemonCount마리 · 선택한 포지션만 사용'
      : '랜덤 후보 $_candidatePokemonCount마리 · 선택하지 않으면 전체 포지션 사용';

  int get _candidatePokemonCount => pokemonList
      .where((pokemon) => _selectedCategories.contains(pokemon['category']))
      .length;

  double get _candidatePokemonProgress =>
      pokemonList.isEmpty ? 0 : _candidatePokemonCount / pokemonList.length;

  List<String> get _selectedCategories {
    final selectedCategories = categories.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    return selectedCategories.isEmpty
        ? categories.keys.toList()
        : selectedCategories;
  }

  int _categoryPokemonCount(String category) {
    return pokemonList
        .where((pokemon) => pokemon['category'] == category)
        .length;
  }

  void _selectAllCategories() {
    setState(() {
      categories.updateAll((key, value) => true);
    });
  }

  void _clearCategories() {
    final previousCategories = Map<String, bool>.from(categories);

    setState(() {
      categories.updateAll((key, value) => false);
    });

    if (previousCategories.values.every((isSelected) => !isSelected)) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('포지션 선택을 모두 해제했습니다.'),
          action: SnackBarAction(
            label: '되돌리기',
            onPressed: () {
              setState(() {
                categories = previousCategories;
              });
            },
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('포켓몬 배정 방식 선택')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 400, // 화면 크기를 400px로 제한
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Text(
                  _selectionSummary,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _candidateSummary,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                LabeledProgressIndicator(
                  value: _candidatePokemonProgress,
                  semanticLabel: '랜덤 후보 포켓몬 범위',
                  semanticValue:
                      '$_candidatePokemonCount/${pokemonList.length}마리',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _selectAllCategories,
                        icon: const Icon(Icons.done_all),
                        label: const Text('전체 선택'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            _hasSelectedCategories ? _clearCategories : null,
                        icon: const Icon(Icons.clear_all),
                        label: const Text('전체 해제'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...categories.keys.map((category) {
                  final isSelected = categories[category] ?? false;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: CheckboxListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).dividerColor,
                        ),
                      ),
                      tileColor: isSelected
                          ? Theme.of(
                              context,
                            )
                              .colorScheme
                              .primaryContainer
                              .withValues(alpha: 0.24)
                          : null,
                      title: Text(
                        category,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('${_categoryPokemonCount(category)}마리 후보'),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          categories[category] = value ?? false;
                        });
                      },
                    ),
                  );
                }),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '배정 방식',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                AppActionTile(
                  icon: Icons.shuffle,
                  title: _randomAssignLabel,
                  description: _hasSelectedCategories
                      ? '선택한 포지션 후보 안에서 10마리를 배정합니다.'
                      : '전체 포지션 후보 안에서 10마리를 배정합니다.',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PokemonAssignmentPage(
                          players: widget.players,
                          selectedCategories: _selectedCategories,
                          assignOneFromEach: false,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                AppActionTile(
                  icon: Icons.grid_view,
                  title: '각 포지션에서 한 마리씩 배정',
                  description: '어택형, 밸런스형, 스피드형, 디펜스형, 서포트형을 팀마다 한 마리씩 배정합니다.',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PokemonAssignmentPage(
                          players: widget.players,
                          selectedCategories: categories.keys.toList(),
                          assignOneFromEach: true,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                AppActionTile(
                  icon: Icons.star_outline,
                  title: '선호 포켓몬 배정',
                  description: '직접 고른 포켓몬 후보 안에서만 배정합니다.',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PreferredPokemonPage(players: widget.players),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                AppActionTile(
                  icon: Icons.block,
                  title: '제외 포켓몬 설정 후 랜덤 배정',
                  description: '선택한 포지션 후보에서 제외할 포켓몬을 뺀 뒤 배정합니다.',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExcludePokemonPage(
                          players: widget.players,
                          selectedCategories: _selectedCategories,
                        ),
                      ),
                    );
                  },
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
