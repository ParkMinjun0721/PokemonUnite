import 'package:flutter/material.dart';
import 'pokemonassign.dart'; // 포켓몬 배정 페이지로 이동하기 위해 불러옴

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
    '서포트형': false
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('포켓몬 카테고리 선택')),
      body: Column(
        children: [
          // 여러 카테고리를 선택할 수 있는 체크박스 리스트
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
          // 첫 번째 옵션: 선택된 카테고리에서 포켓몬을 랜덤으로 배정
          ElevatedButton(
            onPressed: categories.values.contains(true) ? () {
              // 선택된 카테고리들만 추출
              List<String> selectedCategories = categories.entries
                  .where((entry) => entry.value)
                  .map((entry) => entry.key)
                  .toList();

              Navigator.push(context, MaterialPageRoute(
                builder: (context) => PokemonAssignmentPage(
                  players: widget.players,
                  selectedCategories: selectedCategories,
                  assignOneFromEach: false, // 카테고리별 한 마리씩이 아닌 랜덤 배정
                ),
              ));
            } : null,
            child: Text('선택된 카테고리에서 랜덤 배정'),
          ),
          SizedBox(height: 20,),
          // 두 번째 옵션: 각 포지션에서 한 마리씩 배정
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => PokemonAssignmentPage(
                  players: widget.players,
                  selectedCategories: categories.keys.toList(), // 5가지 기본 포지션
                  assignOneFromEach: true, // 각 포지션에서 한 마리씩 배정
                ),
              ));
            },
            child: Text('각 포지션에서 한 마리씩 배정'),
          ),
          SizedBox(height: 20,),
        ],
      ),
    );
  }
}
