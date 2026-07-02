import 'package:flutter/material.dart';
import '../data/pokemon_data.dart';
import 'pokemon_assignment_page.dart';

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
  List<String> excludedPokemon = []; // 제외된 포켓몬 리스트
  String searchQuery = ''; // 검색어

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
                const Text(
                  '선택한 포켓몬은 랜덤 배정 후보에서 제외됩니다.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // 검색창 추가
                TextField(
                  decoration: const InputDecoration(
                    labelText: '포켓몬 검색',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                if (excludedPokemon.isNotEmpty)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 96),
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          ...excludedPokemon.map((pokemonName) {
                            return InputChip(
                              label: Text(pokemonName),
                              onDeleted: () {
                                setState(() {
                                  excludedPokemon.remove(pokemonName);
                                });
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                if (excludedPokemon.isNotEmpty)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          excludedPokemon.clear();
                        });
                      },
                      child: const Text('전체 해제'),
                    ),
                  ),
                const SizedBox(height: 8),
                // 카테고리별 포켓몬 리스트
                Expanded(
                  child: ListView(
                    children: categorizedPokemon.entries.map((entry) {
                      if (entry.value.isEmpty) {
                        return const SizedBox(); // 검색 결과가 없을 경우 표시 안 함
                      }
                      return ExpansionTile(
                        title: Text(
                          entry.key, // 카테고리 이름
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
                                            excludedPokemon.add(pokemonName);
                                          } else {
                                            excludedPokemon.remove(pokemonName);
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
                // 다음 페이지로 이동 버튼
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
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
                    child: const Text('제외 목록으로 랜덤 배정'),
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
