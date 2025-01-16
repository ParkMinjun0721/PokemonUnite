import 'package:flutter/material.dart';
import 'pokemon_assignment_page.dart';
import '../data/pokemon_data.dart';

class PreferredPokemonPage extends StatefulWidget {
  final List<String> players;

  PreferredPokemonPage({required this.players});

  @override
  _PreferredPokemonPageState createState() => _PreferredPokemonPageState();
}

class _PreferredPokemonPageState extends State<PreferredPokemonPage> {
  List<String> selectedPokemon = []; // 선택된 포켓몬 리스트

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
      categories[category]?.add(name);
    }

    return categories;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('선호 포켓몬 선택')),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 400, // 화면 크기를 400px로 제한
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: categorizedPokemon.entries.map((entry) {
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
                        }).toList(),
                      );
                    }).toList(),
                  ),
                ),
                ElevatedButton(
                  onPressed: selectedPokemon.isNotEmpty
                      ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PokemonAssignmentPage(
                          players: widget.players,
                          selectedCategories: [], // 카테고리 없음
                          preferredPokemon: selectedPokemon, // 선택된 포켓몬 전달
                        ),
                      ),
                    );
                  }
                      : null,
                  child: Text('선호 포켓몬으로 배정'),
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
