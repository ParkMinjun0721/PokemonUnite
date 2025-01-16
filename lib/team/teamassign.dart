import 'package:flutter/material.dart';
import 'package:pokemonbattle/team/team_result_page.dart';

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
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
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
                          border: OutlineInputBorder(),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: players.every((name) => name.isNotEmpty)
            ? () {
          // 모든 이름이 입력된 후 팀 배정을 진행
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeamResultPage(players: players),
            ),
          );
        }
            : null,
        child: Icon(Icons.navigate_next),
      ),
    );
  }
}
