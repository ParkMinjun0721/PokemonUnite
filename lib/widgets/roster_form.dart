import 'package:flutter/material.dart';
import 'match_page.dart';

class RosterForm extends StatelessWidget {
  const RosterForm({
    super.key,
    required this.players,
    required this.onChanged,
    required this.onContinue,
    this.fixedTeams = false,
  });

  final List<String> players;
  final void Function(int, String) onChanged;
  final ValueChanged<List<String>> onContinue;
  final bool fixedTeams;

  @override
  Widget build(BuildContext context) {
    final names = players.map((name) => name.trim()).toList();
    final filled = names.where((name) => name.isNotEmpty).length;
    final valid = filled == names.length && names.toSet().length == filled;

    return MatchPage(
      title: fixedTeams ? '팀별 명단 입력' : '참가자 입력',
      action: FilledButton(
        onPressed: valid
            ? () {
                FocusScope.of(context).unfocus();
                onContinue(names);
              }
            : null,
        child: Text(fixedTeams ? '배정 방식 선택' : '팀 나누기'),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('$filled/${names.length}명 입력',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        LinearProgressIndicator(
            value: filled / names.length, semanticsLabel: '명단 입력 진행률'),
        const SizedBox(height: 16),
        for (var i = 0; i < names.length; i++) ...[
          if (fixedTeams && i % 5 == 0)
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: TeamHeading(i ~/ 5 + 1)),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: TextFormField(
                key: ValueKey('player-$i'),
                initialValue: players[i],
                textInputAction: i == names.length - 1
                    ? TextInputAction.done
                    : TextInputAction.next,
                onChanged: (value) => onChanged(i, value),
                decoration: InputDecoration(
                  labelText: fixedTeams
                      ? '${i ~/ 5 + 1}팀 참가자 ${i % 5 + 1}'
                      : '참가자 ${i + 1}',
                  errorText: names[i].isNotEmpty &&
                          names.indexOf(names[i]) != names.lastIndexOf(names[i])
                      ? '같은 이름이 있습니다. 구별할 이름을 입력하세요.'
                      : null,
                  errorMaxLines: 3,
                ),
              )),
        ],
      ]),
    );
  }
}
