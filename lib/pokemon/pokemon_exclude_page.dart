import 'package:flutter/material.dart';
import 'pokemon_assignment_page.dart';
import '../data/pokemon_data.dart';

class ExcludePokemonPage extends StatefulWidget {
  final List<String> players;

  ExcludePokemonPage({required this.players});

  @override
  _ExcludePokemonPageState createState() => _ExcludePokemonPageState();
}

class _ExcludePokemonPageState extends State<ExcludePokemonPage> {
  List<String> excludedPokemon = []; // 제외된 포켓몬 리스트
  String searchQuery = ''; // 검색어

  // 포켓몬을 카테고리별로 분류하고 제외된 포켓몬 필터링
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
      if (!excludedPokemon.contains(name) &&
          name.toLowerCase().contains(searchQuery.toLowerCase())) {
        categories[category]?.add(name);
      }
    }

    return categories;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('제외할 포켓몬 선택')),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 400, // 화면 크기를 400px로 제한
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 검색창 추가
                TextField(
                  decoration: InputDecoration(
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
                SizedBox(height: 16),
                // 카테고리별 포켓몬 리스트
                Expanded(
                  child: ListView(
                    children: categorizedPokemon.entries.map((entry) {
                      if (entry.value.isEmpty) return SizedBox(); // 검색 결과가 없을 경우 표시 안 함
                      return ExpansionTile(
                        title: Text(
                          entry.key, // 카테고리 이름
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        children: entry.value.map((pokemonName) {
                          return FilterChip(
                            label: Text(pokemonName),
                            selected: excludedPokemon.contains(pokemonName),
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
                        }).toList(),
                      );
                    }).toList(),
                  ),
                ),
                // 제외된 포켓몬 미리보기
                // Wrap(
                //   spacing: 8,
                //   runSpacing: 4,
                //   children: excludedPokemon.map((pokemon) {
                //     return Chip(
                //       label: Text(pokemon),
                //       deleteIcon: Icon(Icons.close),
                //       onDeleted: () {
                //         setState(() {
                //           excludedPokemon.remove(pokemon);
                //         });
                //       },
                //     );
                //   }).toList(),
                // ),
                SizedBox(height: 16),
                // 다음 페이지로 이동 버튼
                ElevatedButton(
                  onPressed: excludedPokemon.isNotEmpty
                      ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PokemonAssignmentPage(
                          players: widget.players,
                          selectedCategories: [], // 선택된 카테고리 없음
                          preferredPokemon: [], // 선호 포켓몬 없음
                        ),
                      ),
                    );
                  }
                      : null,
                  child: Text('선호 포켓몬 배정 제외 완료'),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
