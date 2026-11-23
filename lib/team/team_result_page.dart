import 'package:flutter/material.dart';
import 'package:pokemonbattle/widgets/assignment_error_view.dart';
import 'team_assignment_logic.dart';

class TeamResultPage extends StatefulWidget {
  final List<String> players;

  const TeamResultPage({super.key, required this.players});

  @override
  State<TeamResultPage> createState() => _TeamResultPageState();
}

class _TeamResultPageState extends State<TeamResultPage> {
  late final TeamAssignmentLogic logic;
  final ScrollController _scrollController = ScrollController();
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
        _scrollToTop();
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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
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
        Text(
          '총 ${assignedResult.team1.length + assignedResult.team2.length}명 배정 완료',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            controller: _scrollController,
            children: [
              _buildTeamHeader('1팀', assignedResult.team1.length),
              ...assignedResult.team1.indexed.map(
                (entry) => _buildPlayerTile('1팀', entry.$2, entry.$1),
              ),
              const SizedBox(height: 20),
              _buildTeamHeader('2팀', assignedResult.team2.length),
              ...assignedResult.team2.indexed.map(
                (entry) => _buildPlayerTile('2팀', entry.$2, entry.$1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _assignTeams,
            icon: const Icon(Icons.shuffle),
            label: const Text('다시 배정'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.edit),
            label: const Text('입력으로 돌아가기'),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamHeader(String teamName, int memberCount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(Icons.groups, size: 22),
          const SizedBox(width: 8),
          Text(
            '$teamName $memberCount명',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerTile(String teamName, String player, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        leading: CircleAvatar(
          radius: 14,
          child: Text('${index + 1}'),
        ),
        title: Text(player),
        subtitle: Text('$teamName ${index + 1}번 참가자'),
      ),
    );
  }

  Widget _buildErrorBody(BuildContext context) {
    return AssignmentErrorView(
      title: assignmentError ?? '팀 배정에 실패했습니다.',
      message: '참가자 이름을 다시 확인해주세요.',
      onBack: () => Navigator.pop(context),
    );
  }
}
