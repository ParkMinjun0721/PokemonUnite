import 'package:flutter/material.dart';
import 'package:pokemonbattle/team/team_assignment_logic.dart';
import 'package:pokemonbattle/team/team_result_page.dart';

class TeamAssignmentPage extends StatefulWidget {
  const TeamAssignmentPage({super.key});

  @override
  State<TeamAssignmentPage> createState() => _TeamAssignmentPageState();
}

class _TeamAssignmentPageState extends State<TeamAssignmentPage> {
  List<String> players = List.filled(10, ''); // 10개의 빈 문자열로 초기화
  final TeamAssignmentLogic _logic = TeamAssignmentLogic();
  late final List<TextEditingController> _controllers;

  bool get _hasValidPlayers => _logic.hasValidPlayers(players);

  List<String> get _trimmedPlayers => _logic.trimPlayers(players);

  int get _enteredPlayerCount =>
      players.where((name) => name.trim().isNotEmpty).length;

  bool get _hasEnteredPlayers => _enteredPlayerCount > 0;

  String get _helperText =>
      _hasValidPlayers ? '참가자 10명이 준비되었습니다.' : '중복 없는 참가자 10명을 입력해주세요.';

  void _goToResultPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeamResultPage(players: _trimmedPlayers),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(10, (index) => TextEditingController());
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _clearPlayers() {
    for (final controller in _controllers) {
      controller.clear();
    }

    setState(() {
      players = List.filled(10, '');
    });
  }

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
                  Text(
                    '입력 $_enteredPlayerCount/10명',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _helperText,
                    style: _hasValidPlayers
                        ? null
                        : const TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                  if (_hasEnteredPlayers)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _clearPlayers,
                        child: const Text('전체 초기화'),
                      ),
                    ),
                  const SizedBox(height: 8),
                  ...List.generate(10, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextField(
                        controller: _controllers[index],
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
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _hasValidPlayers ? _goToResultPage : null,
                      child: const Text('팀 랜덤 배정'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
