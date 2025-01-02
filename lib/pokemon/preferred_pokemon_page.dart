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

  List<String> get allPokemonNames => pokemonList.map((p) => p['name']!).toList(); //모든 포켓몬 리스트 가져오기.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('선호 포켓몬 선택')),
      body: Column(
        children: [
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: allPokemonNames.map((pokemonName) {
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
    );
  }
}
