import 'dart:math';
import 'package:flutter/material.dart';

class TeamAssignmentPage extends StatefulWidget {
  @override
  _TeamAssignmentPageState createState() => _TeamAssignmentPageState();
}

class _TeamAssignmentPageState extends State<TeamAssignmentPage> {
  List<String> players = List.filled(10, ''); // 10개의 빈 문자열로 초기화

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('팀 배정 입력')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ...List.generate(10, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        players[index] = value; // 플레이어 이름 입력
                      });
                    },
                    decoration: InputDecoration(
                      hintText: '플레이어 ${index + 1} 이름 입력',
                      border: OutlineInputBorder(),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: players.every((name) => name.isNotEmpty) ? () {
          // 모든 이름이 입력된 후 팀 배정을 진행
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => TeamResultPage(players: players)
          ));
        } : null,
        child: Icon(Icons.navigate_next),
      ),
    );
  }
}

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
      body: Padding(
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
    );
  }
}
