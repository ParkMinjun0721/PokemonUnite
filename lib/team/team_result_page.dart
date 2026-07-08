import 'package:flutter/material.dart';
import 'team_assignment_logic.dart';

class TeamResultPage extends StatefulWidget {
  final List<String> players;

  const TeamResultPage({super.key, required this.players});

  @override
  State<TeamResultPage> createState() => _TeamResultPageState();
}

class _TeamResultPageState extends State<TeamResultPage> {
  late final TeamAssignmentLogic logic;
  TeamAssignmentResult? result;
  String? assignmentError;

  @override
  void initState() {
    super.initState();
    logic = TeamAssignmentLogic();
    _assignTeams(notify: false);
  }

  void _assignTeams({bool notify = true}) {
    try {
      final assignedResult = logic.assignTeams(widget.players);

      void updateResult() {
        result = assignedResult;
        assignmentError = null;
      }

      if (notify) {
        setState(updateResult);
      } else {
        updateResult();
      }
    } on TeamAssignmentException catch (error) {
      void updateError() {
        result = null;
        assignmentError = error.message;
      }

      if (notify) {
        setState(updateError);
      } else {
        updateError();
      }
    }
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
            child: assignmentError == null
                ? _buildResultBody()
                : _buildErrorBody(context),
          ),
        ),
      ),
    );
  }

  Widget _buildResultBody() {
    final assignedResult = result;

    if (assignedResult == null) {
      return _buildErrorBody(context);
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              const Text(
                '1팀:',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              ...assignedResult.team1.map(
                (player) => ListTile(title: Text(player)),
              ),
              const SizedBox(height: 20),
              const Text(
                '2팀:',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              ...assignedResult.team2.map(
                (player) => ListTile(title: Text(player)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _assignTeams,
            child: const Text('다시 배정'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('입력으로 돌아가기'),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBody(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
        const SizedBox(height: 16),
        Text(
          assignmentError ?? '팀 배정에 실패했습니다.',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Text('참가자 이름을 다시 확인해주세요.', textAlign: TextAlign.center),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('이전으로'),
        ),
      ],
    );
  }
}
