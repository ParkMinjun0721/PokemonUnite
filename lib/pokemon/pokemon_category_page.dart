import 'package:flutter/material.dart';
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

  List<String> get _selectedCategories {
    final selectedCategories = categories.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    return selectedCategories.isEmpty
        ? categories.keys.toList()
        : selectedCategories;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('포켓몬 카테고리 선택')),
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
                  _selectionSummary,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  '아무 포지션도 선택하지 않으면 전체 포지션에서 랜덤 배정됩니다.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            categories.updateAll((key, value) => true);
                          });
                        },
                        child: const Text('전체 선택'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _hasSelectedCategories
                            ? () {
                                setState(() {
                                  categories.updateAll((key, value) => false);
                                });
                              }
                            : null,
                        child: const Text('전체 해제'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    children: categories.keys.map((category) {
                      return CheckboxListTile(
                        title: Text(category),
                        value: categories[category],
                        onChanged: (bool? value) {
                          setState(() {
                            categories[category] = value ?? false;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
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
                    child: Text(_randomAssignLabel),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
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
                    child: const Text('각 포지션에서 한 마리씩 배정'),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PreferredPokemonPage(players: widget.players),
                        ),
                      );
                    },
                    child: const Text('선호 포켓몬 배정'),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
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
                    child: const Text('제외 포켓몬 설정 후 랜덤 배정'),
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
