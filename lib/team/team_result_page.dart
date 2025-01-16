import 'package:flutter/material.dart';

class TeamResultPage extends StatelessWidget {
  final List<String> players;

  TeamResultPage({required this.players});

  @override
  Widget build(BuildContext context) {
    // 플레이어들을 랜덤하게 섞음
    List<String> shuffledPlayers = List.from(players)..shuffle();

    // 1팀: 섞인 리스트의 첫 5명, 2팀: 나머지 5명
    List<String> team1 = shuffledPlayers.sublist(0, 5);
    List<String> team2 = shuffledPlayers.sublist(5, 10);

    return Scaffold(
      appBar: AppBar(title: Text('팀 배정 결과')),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 400, // 웹에서도 화면 크기를 400px로 제한
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('1팀:', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ...team1.map((player) => ListTile(title: Text(player))).toList(),
                SizedBox(height: 20),
                Text('2팀:', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ...team2.map((player) => ListTile(title: Text(player))).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
