import 'package:flutter/material.dart';

// 모든 참가자의 포켓몬 할당 결과를 보여주는 결과 페이지
class ResultsPage extends StatelessWidget {
  final Map<String, Map<String, String>> playerPokemonMap;
  final List<String> team1;
  final List<String> team2;

  ResultsPage({required this.playerPokemonMap, required this.team1, required this.team2});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('포켓몬 할당 결과')),
      body: ListView(
        children: [
          Text('1팀:', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ...team1.map((player) {
            final pokemon = playerPokemonMap[player];
            return ListTile(
              title: Text('$player: ${pokemon?['name']}'),
              leading: Image.asset(pokemon?['image'] ?? ''),
            );
          }).toList(),
          Text('2팀:', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ...team2.map((player) {
            final pokemon = playerPokemonMap[player];
            return ListTile(
              title: Text('$player: ${pokemon?['name']}'),
              leading: Image.asset(pokemon?['image'] ?? ''),
            );
          }).toList(),
        ],
      ),
    );
  }
}
