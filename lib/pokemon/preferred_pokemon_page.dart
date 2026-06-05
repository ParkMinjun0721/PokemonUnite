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
                const SizedBox(height: 16),
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
                          ...entry.value.map((pokemonName) {
                            return FilterChip(
                              label: Text(pokemonName),
                              selected: selectedPokemon.contains(pokemonName),
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
                      );
                    }).toList(),
                  ),
                ),
                if (selectedPokemon.isNotEmpty && selectedPokemon.length < 5)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      '선호 포켓몬은 최소 5마리 이상 선택해주세요.',
                      style: TextStyle(color: Colors.redAccent),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 16),
                // 다음 페이지로 이동 버튼
                ElevatedButton(
                  onPressed: selectedPokemon.length >= 5
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PokemonAssignmentPage(
                                players: widget.players,
                                selectedCategories: const [], // 카테고리 없음
                                preferredPokemon: selectedPokemon, // 선택된 포켓몬 전달
                              ),
                            ),
                          );
                        }
                      : null,
                  child: const Text('선호 포켓몬으로 배정'),
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
