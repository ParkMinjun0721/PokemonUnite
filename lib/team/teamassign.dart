import 'package:flutter/material.dart';
import 'package:pokemonbattle/team/team_result_page.dart';

class TeamAssignmentPage extends StatefulWidget {
  const TeamAssignmentPage({super.key});

  @override
  State<TeamAssignmentPage> createState() => _TeamAssignmentPageState();
}

class _TeamAssignmentPageState extends State<TeamAssignmentPage> {
  List<String> players = List.filled(10, ''); // 10개의 빈 문자열로 초기화

  bool get _hasValidPlayers {
    final trimmedPlayers = players.map((name) => name.trim()).toList();
    return trimmedPlayers.every((name) => name.isNotEmpty) &&
        trimmedPlayers.toSet().length == trimmedPlayers.length;
  }

  List<String> get _trimmedPlayers =>
      players.map((name) => name.trim()).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('팀 배정 입력')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 400, // 웹에서도 화면 크기를 400px로 제한
          ),
          child: SingleChildScrollView(
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
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    );
                  }),
                  if (players.any((name) => name.trim().isNotEmpty) &&
                      !_hasValidPlayers)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        '이름은 공백 없이 입력하고, 중복되지 않아야 합니다.',
                        style: TextStyle(color: Colors.redAccent),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _hasValidPlayers
            ? () {
                // 모든 이름이 입력된 후 팀 배정을 진행
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TeamResultPage(players: _trimmedPlayers),
                  ),
                );
              }
            : null,
        child: const Icon(Icons.navigate_next),
      ),
    );
  }
}
