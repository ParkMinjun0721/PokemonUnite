import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'match_page.dart';
import 'roster_paste_page.dart';

class RosterForm extends StatefulWidget {
  const RosterForm({
    super.key,
    required this.players,
    required this.onChanged,
    required this.onContinue,
    required this.onReplace,
    this.fixedTeams = false,
  });

  final List<String> players;
  final void Function(int, String) onChanged;
  final ValueChanged<List<String>> onContinue;
  final ValueChanged<List<String>> onReplace;
  final bool fixedTeams;

  @override
  State<RosterForm> createState() => _RosterFormState();
}

class _RosterFormState extends State<RosterForm> {
  late final controllers =
      widget.players.map((name) => TextEditingController(text: name)).toList();

  @override
  void didUpdateWidget(RosterForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    for (var i = 0; i < controllers.length; i++) {
      if (controllers[i].text != widget.players[i]) {
        controllers[i].text = widget.players[i];
      }
    }
  }

  @override
  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _openPastePage() async {
    FocusScope.of(context).unfocus();
    final names = await Navigator.of(context).push<List<String>>(
      MaterialPageRoute(
          builder: (_) => RosterPastePage(fixedTeams: widget.fixedTeams)),
    );
    if (mounted && names != null) widget.onReplace(names);
  }

  @override
  Widget build(BuildContext context) {
    final names = widget.players.map((name) => name.trim()).toList();
    final filled = names.where((name) => name.isNotEmpty).length;
    final valid = filled == names.length && names.toSet().length == filled;

    return MatchPage(
      title: widget.fixedTeams ? '팀별 명단 입력' : '참가자 입력',
      action: FilledButton(
        onPressed: valid
            ? () {
                FocusScope.of(context).unfocus();
                widget.onContinue(names);
              }
            : null,
        child: Text(widget.fixedTeams ? '배정 방식 선택' : '팀 나누기'),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              Text('$filled/${names.length}명 입력',
                  style: Theme.of(context).textTheme.titleLarge),
              TextButton.icon(
                  onPressed: _openPastePage,
                  icon: const Icon(Icons.content_paste),
                  label: const Text('명단 붙여넣기')),
            ]),
        const SizedBox(height: 10),
        LinearProgressIndicator(
            value: filled / names.length, semanticsLabel: '명단 입력 진행률'),
        const SizedBox(height: 16),
        for (var i = 0; i < names.length; i++) ...[
          if (widget.fixedTeams && i % 5 == 0)
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: TeamHeading(i ~/ 5 + 1)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Focus(
              canRequestFocus: false,
              child: Builder(builder: (context) {
                final label = widget.fixedTeams
                    ? '${i ~/ 5 + 1}팀 참가자 ${i % 5 + 1}'
                    : '참가자 ${i + 1}';
                // Flutter web syncs the native input value when it receives focus.
                final readName = kIsWeb &&
                    names[i].isNotEmpty &&
                    !Focus.of(context).hasFocus;
                return TextFormField(
                  key: ValueKey('player-$i'),
                  controller: controllers[i],
                  textInputAction: i == names.length - 1
                      ? TextInputAction.done
                      : TextInputAction.next,
                  onChanged: (value) => widget.onChanged(i, value),
                  decoration: InputDecoration(
                    label: Text(label,
                        semanticsLabel:
                            readName ? '$label, ${names[i]}' : label),
                    errorText: names[i].isNotEmpty &&
                            names.indexOf(names[i]) !=
                                names.lastIndexOf(names[i])
                        ? '같은 이름이 있습니다. 구별할 이름을 입력하세요.'
                        : null,
                    errorMaxLines: 3,
                  ),
                );
              }),
            ),
          ),
        ],
      ]),
    );
  }
}
