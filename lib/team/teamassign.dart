import 'package:flutter/material.dart';
import '../widgets/roster_form.dart';
import 'team_result_page.dart';

class TeamAssignmentPage extends StatefulWidget {
  const TeamAssignmentPage({super.key});

  @override
  State<TeamAssignmentPage> createState() => _TeamAssignmentPageState();
}

class _TeamAssignmentPageState extends State<TeamAssignmentPage> {
  List<String> players = List.filled(10, '');

  @override
  Widget build(BuildContext context) {
    return RosterForm(
      players: players,
      onChanged: (index, value) => setState(() => players[index] = value),
      onReplace: (names) => setState(() => players = names),
      onContinue: (names) => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => TeamResultPage(players: names)),
      ),
    );
  }
}
