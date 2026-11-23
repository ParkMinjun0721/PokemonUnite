import 'dart:convert';

import 'package:flutter/material.dart';

import 'match_page.dart';

class RosterPastePage extends StatefulWidget {
  const RosterPastePage({super.key, required this.fixedTeams});

  final bool fixedTeams;

  @override
  State<RosterPastePage> createState() => _RosterPastePageState();
}

class _RosterPastePageState extends State<RosterPastePage> {
  String draft = '';

  @override
  Widget build(BuildContext context) {
    final names = <String>[];
    final linesByName = <String, List<int>>{};
    final lines = const LineSplitter().convert(draft);
    for (var i = 0; i < lines.length; i++) {
      final name = lines[i].trim();
      if (name.isEmpty) continue;
      names.add(name);
      (linesByName[name] ??= []).add(i + 1);
    }

    final duplicates =
        linesByName.entries.where((entry) => entry.value.length > 1);
    final valid = names.length == 10 && duplicates.isEmpty;
    final theme = Theme.of(context);
    return MatchPage(
      title: '명단 붙여넣기',
      action: FilledButton(
        onPressed: valid ? () => Navigator.pop(context, names) : null,
        child: const Text('명단 적용'),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(widget.fixedTeams
            ? '이름을 한 줄에 한 명씩 붙여넣으세요. 앞 5명은 1팀, 뒤 5명은 2팀입니다.'
            : '이름을 한 줄에 한 명씩 붙여넣으세요. 참가자 10명을 두 팀으로 나눕니다.'),
        const SizedBox(height: 16),
        TextField(
          minLines: 4,
          maxLines: 7,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          decoration: const InputDecoration(
              labelText: '참가자 명단', alignLabelWithHint: true),
          onChanged: (value) => setState(() => draft = value),
        ),
        const SizedBox(height: 12),
        Semantics(
          container: true,
          liveRegion: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${names.length}/10명 입력', style: theme.textTheme.titleMedium),
              if (names.length > 10) Text('참가자를 ${names.length - 10}명 줄여 주세요.'),
              if (names.isNotEmpty && names.length < 10)
                Text('참가자 ${10 - names.length}명을 더 입력해 주세요.'),
              for (final entry in duplicates)
                Text('${entry.value.join(', ')}번째 줄의 이름이 같습니다. ${entry.key}',
                    style: TextStyle(color: theme.colorScheme.error)),
              if (valid) const Text('명단을 적용할 수 있습니다.'),
            ],
          ),
        ),
        if (valid && widget.fixedTeams)
          for (var team = 0; team < 2; team++) ...[
            const SizedBox(height: 16),
            TeamHeading(team + 1),
            const SizedBox(height: 4),
            Text(names.skip(team * 5).take(5).join(' · ')),
          ],
        Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            )),
      ]),
    );
  }
}
