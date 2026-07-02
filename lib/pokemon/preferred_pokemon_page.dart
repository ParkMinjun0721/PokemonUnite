import 'package:flutter/material.dart';
import 'pokemon_assignment_page.dart';
import '../data/pokemon_data.dart';

class PreferredPokemonPage extends StatefulWidget {
  final List<String> players;

  const PreferredPokemonPage({super.key, required this.players});

  @override
  State<PreferredPokemonPage> createState() => _PreferredPokemonPageState();
}

class _PreferredPokemonPageState extends State<PreferredPokemonPage> {
  List<String> selectedPokemon = []; // 선택된 포켓몬 리스트
  String searchQuery = ''; // 검색어

  bool get canAssign => selectedPokemon.length >= 5;
  bool get hasSelectedPokemon => selectedPokemon.isNotEmpty;
  String get helperText =>
      canAssign ? '선택한 포켓몬 후보 안에서 랜덤 배정됩니다.' : '선호 포켓몬은 최소 5마리 이상 선택해주세요.';

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
                if (hasSelectedPokemon)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 96),
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          ...selectedPokemon.map((pokemonName) {
                            return InputChip(
                              label: Text(pokemonName),
                              onDeleted: () {
                                setState(() {
                                  selectedPokemon.remove(pokemonName);
                                });
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                if (hasSelectedPokemon)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          selectedPokemon.clear();
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
                                      selected: selectedPokemon.contains(
                                        pokemonName,
                                      ),
                                      onSelected: (bool selected) {
                                        setState(() {
                                          if (selected) {
                                            selectedPokemon.add(pokemonName);
                                          } else {
                                            selectedPokemon.remove(pokemonName);
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
                                  selectedCategories: const [], // 카테고리 없음
                                  preferredPokemon:
                                      selectedPokemon, // 선택된 포켓몬 전달
                                ),
                              ),
                            );
                          }
                        : null,
                    child: const Text('선호 포켓몬으로 배정'),
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
