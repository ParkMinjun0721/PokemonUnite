import 'package:flutter/material.dart';
import 'pokemon_assignment_page.dart';
import 'preferred_pokemon_page.dart';

class PokemonCategoryPage extends StatefulWidget {
  final List<String> players;

  PokemonCategoryPage({required this.players});

  @override
  _PokemonCategoryPageState createState() => _PokemonCategoryPageState();
}

class _PokemonCategoryPageState extends State<PokemonCategoryPage> {
  Map<String, bool> categories = {
    '어택형': false,
    '밸런스형': false,
    '스피드형': false,
    '디펜스형': false,
    '서포트형': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('포켓몬 카테고리 선택')),
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
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: categories.values.contains(true)
                        ? () {
                      List<String> selectedCategories = categories.entries
                          .where((entry) => entry.value)
                          .map((entry) => entry.key)
                          .toList();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PokemonAssignmentPage(
                            players: widget.players,
                            selectedCategories: selectedCategories,
                            assignOneFromEach: false,
                          ),
                        ),
                      );
                    }
                        : null,
                    child: Text('선택된 카테고리에서 랜덤 배정'),
                  ),
                ),
                SizedBox(height: 16),
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
                    child: Text('각 포지션에서 한 마리씩 배정'),
                  ),
                ),
                SizedBox(height: 16),
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
                    child: Text('선호 포켓몬 배정'),
                  ),
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
