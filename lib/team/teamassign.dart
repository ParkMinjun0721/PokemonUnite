import 'package:flutter/material.dart';
import 'package:pokemonbattle/team/team_assignment_logic.dart';
import 'package:pokemonbattle/team/team_result_page.dart';
import 'package:pokemonbattle/widgets/labeled_progress_indicator.dart';

class TeamAssignmentPage extends StatefulWidget {
  const TeamAssignmentPage({super.key});

  @override
  State<TeamAssignmentPage> createState() => _TeamAssignmentPageState();
}

class _TeamAssignmentPageState extends State<TeamAssignmentPage> {
  List<String> players = List.filled(10, ''); // 10개의 빈 문자열로 초기화
  final TeamAssignmentLogic _logic = TeamAssignmentLogic();
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  bool get _hasValidPlayers => _logic.hasValidPlayers(players);

  List<String> get _trimmedPlayers => _logic.trimPlayers(players);

  int get _enteredPlayerCount =>
      players.where((name) => name.trim().isNotEmpty).length;

  bool get _hasEnteredPlayers => _enteredPlayerCount > 0;

  int get _remainingPlayerCount => players.length - _enteredPlayerCount;

  double get _enteredPlayerProgress => _enteredPlayerCount / players.length;

  List<String> get _duplicatedPlayers {
    final seenPlayers = <String>{};
    final duplicatedPlayers = <String>{};

    for (final player in _trimmedPlayers.where((name) => name.isNotEmpty)) {
      if (!seenPlayers.add(player)) {
        duplicatedPlayers.add(player);
      }
    }

    return duplicatedPlayers.toList();
  }

  bool _isDuplicatedPlayerAt(int index) {
    final player = players[index].trim();
    if (player.isEmpty) {
      return false;
    }

    return _trimmedPlayers.where((name) => name == player).length > 1;
  }

  String get _helperText {
    if (_hasValidPlayers) {
      return '참가자 10명이 준비되었습니다.';
    }

    if (_duplicatedPlayers.isNotEmpty) {
      return '중복된 이름: ${_duplicatedPlayers.join(', ')}';
    }

    if (_hasEnteredPlayers) {
      return '참가자 $_remainingPlayerCount명을 더 입력해주세요.';
    }

    return '중복 없는 참가자 10명을 입력해주세요.';
  }

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
    _focusNodes = List.generate(10, (index) => FocusNode());
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _clearPlayers() {
    final previousPlayers = List<String>.from(players);

    for (final controller in _controllers) {
      controller.clear();
    }
    for (final focusNode in _focusNodes) {
      focusNode.unfocus();
    }

    setState(() {
      players = List.filled(10, '');
    });

    if (previousPlayers.every((player) => player.trim().isEmpty)) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('참가자 입력을 모두 지웠습니다.'),
          action: SnackBarAction(
            label: '되돌리기',
            onPressed: () {
              for (var index = 0; index < _controllers.length; index++) {
                _controllers[index].text = previousPlayers[index];
              }

              setState(() {
                players = previousPlayers;
              });
            },
          ),
        ),
      );
  }

  void _clearPlayerAt(int index) {
    _controllers[index].clear();
    _focusNodes[index].requestFocus();

    setState(() {
      players[index] = '';
    });
  }

  void _handleSubmitted(int index) {
    if (index < _focusNodes.length - 1) {
      _focusNodes[index + 1].requestFocus();
      return;
    }

    _focusNodes[index].unfocus();
    if (_hasValidPlayers) {
      _goToResultPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('팀 배정 입력')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 600, // 웹에서도 입력 흐름을 넓게 쓰되 과도하게 벌어지지 않게 제한
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
                  const SizedBox(height: 8),
                  LabeledProgressIndicator(
                    value: _enteredPlayerProgress,
                    semanticLabel: '팀 배정 참가자 입력 진행률',
                    semanticValue: '$_enteredPlayerCount/10명',
                  ),
                  if (_hasEnteredPlayers)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _clearPlayers,
                        icon: const Icon(Icons.restart_alt),
                        label: const Text('전체 초기화'),
                      ),
                    ),
                  const SizedBox(height: 8),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final useSingleColumn = constraints.maxWidth < 520;
                      final teamSections = List.generate(
                        2,
                        (team) => _buildTeamInputSection(team),
                      );

                      if (useSingleColumn) {
                        return Column(
                          children: [
                            teamSections[0],
                            const SizedBox(height: 12),
                            teamSections[1],
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: teamSections[0]),
                          const SizedBox(width: 16),
                          Expanded(child: teamSections[1]),
                        ],
                      );
                    },
                  ),
                  if (players.any((name) => name.trim().isNotEmpty) &&
                      !_hasValidPlayers)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        '이름은 빈칸 없이 입력하고, 중복되지 않아야 합니다.',
                        style: TextStyle(color: Colors.redAccent),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _hasValidPlayers ? _goToResultPage : null,
                      icon: const Icon(Icons.shuffle),
                      label: const Text('팀 랜덤 배정'),
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

  Widget _buildTeamInputSection(int team) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${team + 1}팀 참가자',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...List.generate(5, (offset) {
          final index = team * 5 + offset;
          final fieldLabel = '${team + 1}팀 참가자 ${offset + 1}';

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              textInputAction:
                  index == 9 ? TextInputAction.done : TextInputAction.next,
              onSubmitted: (_) => _handleSubmitted(index),
              onChanged: (value) {
                setState(() {
                  players[index] = value;
                });
              },
              decoration: InputDecoration(
                labelText: fieldLabel,
                hintText: '$fieldLabel 이름 입력',
                suffixIcon: players[index].trim().isNotEmpty
                    ? IconButton(
                        tooltip: '$fieldLabel 지우기',
                        onPressed: () => _clearPlayerAt(index),
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                errorText: _isDuplicatedPlayerAt(index) ? '중복된 이름' : null,
              ),
            ),
          );
        }),
      ],
    );
  }
}
