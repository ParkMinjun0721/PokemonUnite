import 'package:flutter/material.dart';
import '../widgets/match_page.dart';
import 'pokemon_assignment_page.dart';
import 'preferred_pokemon_page.dart';
import 'pokemon_exclude_page.dart';

enum _Mode {
  balanced('팀마다 역할군별 1마리'),
  roles('선택한 역할군에서 랜덤'),
  preferred('선호 목록에서 랜덤'),
  excluding('포켓몬 제외 후 랜덤');

  const _Mode(this.label);
  final String label;
}

const pokemonRoles = ['어택형', '밸런스형', '스피드형', '디펜스형', '서포트형'];

class PokemonCategoryPage extends StatefulWidget {
  const PokemonCategoryPage({super.key, required this.players});
  final List<String> players;

  @override
  State<PokemonCategoryPage> createState() => _PokemonCategoryPageState();
}

class _PokemonCategoryPageState extends State<PokemonCategoryPage> {
  _Mode mode = _Mode.balanced;
  final selected = <String>{};

  void _continue() {
    final roles = selected.isEmpty ? pokemonRoles : selected.toList();
    final page = switch (mode) {
      _Mode.preferred => PreferredPokemonPage(players: widget.players),
      _Mode.excluding =>
        ExcludePokemonPage(players: widget.players, selectedCategories: roles),
      _Mode.balanced || _Mode.roles => PokemonAssignmentPage(
          players: widget.players,
          selectedCategories: mode == _Mode.balanced ? pokemonRoles : roles,
          assignOneFromEach: mode == _Mode.balanced,
        ),
    };
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MatchPage(
      title: '배정 방식 선택',
      action: FilledButton(
        onPressed: _continue,
        child: Text(switch (mode) {
          _Mode.preferred => '선호 포켓몬 선택',
          _Mode.excluding => '제외할 포켓몬 선택',
          _ => '포켓몬 배정하기',
        }),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('한 팀 안에서는 서로 다른 포켓몬을 배정합니다. 상대 팀에는 같은 포켓몬이 나올 수 있습니다.',
            style: theme.textTheme.bodyLarge),
        const SizedBox(height: 20),
        for (final option in _Mode.values) ...[
          RadioListTile<_Mode>(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            value: option,
            groupValue: mode,
            tileColor:
                mode == option ? theme.colorScheme.primaryContainer : null,
            onChanged: (value) => setState(() => mode = value!),
            title: Text(option.label),
          ),
          if (mode == option &&
              (option == _Mode.roles || option == _Mode.excluding))
            Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(selected.isEmpty
                          ? '선택 없음 · 전체 역할군 사용'
                          : '역할군 ${selected.length}개 선택'),
                      Wrap(spacing: 8, children: [
                        for (final role in pokemonRoles)
                          FilterChip(
                              label: Text(role),
                              selected: selected.contains(role),
                              onSelected: (enabled) => setState(() {
                                    if (enabled) {
                                      selected.add(role);
                                    } else {
                                      selected.remove(role);
                                    }
                                  })),
                      ]),
                      Wrap(children: [
                        TextButton(
                            onPressed: () =>
                                setState(() => selected.addAll(pokemonRoles)),
                            child: const Text('전체 선택')),
                        TextButton(
                            onPressed: selected.isEmpty
                                ? null
                                : () => setState(selected.clear),
                            child: const Text('전체 해제')),
                      ]),
                    ])),
          const SizedBox(height: 8),
        ],
      ]),
    );
  }
}
