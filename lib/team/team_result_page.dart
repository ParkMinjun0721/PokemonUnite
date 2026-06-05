import 'package:flutter/material.dart';

class TeamResultPage extends StatefulWidget {
  final List<String> players;

  const TeamResultPage({super.key, required this.players});

  @override
  State<TeamResultPage> createState() => _TeamResultPageState();
}

class _TeamResultPageState extends State<TeamResultPage> {
  late final List<String> team1;
  late final List<String> team2;

  @override
  void initState() {
    super.initState();

    final shuffledPlayers = List<String>.from(widget.players)..shuffle();
    team1 = shuffledPlayers.sublist(0, 5);
    team2 = shuffledPlayers.sublist(5, 10);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('팀 배정 결과')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 400, // 웹에서도 화면 크기를 400px로 제한
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '1팀:',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                ...team1.map((player) => ListTile(title: Text(player))),
                const SizedBox(height: 20),
                const Text(
                  '2팀:',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                ...team2.map((player) => ListTile(title: Text(player))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
