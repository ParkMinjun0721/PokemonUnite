import 'package:flutter/material.dart';
import 'pokemon_assignment_logic.dart';
import 'result_page.dart';
import '../widgets/match_page.dart';

class PokemonAssignmentPage extends StatefulWidget {
  final List<String> players;
  final List<String> selectedCategories;
  final List<String> preferredPokemon;
  final bool assignOneFromEach;

  const PokemonAssignmentPage({
    super.key,
    required this.players,
    required this.selectedCategories,
    this.preferredPokemon = const [],
    this.assignOneFromEach = false,
  });

  @override
  State<PokemonAssignmentPage> createState() => _PokemonAssignmentPageState();
}

class _PokemonAssignmentPageState extends State<PokemonAssignmentPage> {
  late final PokemonAssignmentLogic logic;
  late Map<String, Map<String, String>> playerPokemonMap;
  late List<String> team1;
  late List<String> team2;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String? assignmentError;

  @override
  void initState() {
    super.initState();
    logic = PokemonAssignmentLogic();
    playerPokemonMap = {};
    team1 = widget.players.sublist(0, 5);
    team2 = widget.players.sublist(5, 10);

    _assignPokemon();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _assignPokemon() {
    try {
      if (widget.preferredPokemon.isNotEmpty) {
        logic.assignPreferredPokemon(
          preferredPokemon: widget.preferredPokemon,
          team1: team1,
          team2: team2,
          playerPokemonMap: playerPokemonMap,
        );
      } else if (widget.assignOneFromEach) {
        logic.assignOnePokemonFromEachCategory(
          selectedCategories: widget.selectedCategories,
          team1: team1,
          team2: team2,
          playerPokemonMap: playerPokemonMap,
        );
      } else {
        logic.assignPokemonFromSelectedCategories(
          selectedCategories: widget.selectedCategories,
          team1: team1,
          team2: team2,
          playerPokemonMap: playerPokemonMap,
        );
      }
    } on PokemonAssignmentException catch (error) {
      assignmentError = error.message;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (assignmentError != null) {
      return MatchPage(
        title: '배정 조건 확인',
        action: FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('조건 수정하기')),
        child: Text(assignmentError!),
      );
    }

    final total = widget.players.length;
    final isSummary = _currentPage == total;
    return Scaffold(
      appBar: AppBar(title: Text(isSummary ? '전체 배정 결과' : '개인별 포켓몬')),
      body: SafeArea(
          top: false,
          child: Column(children: [
            Expanded(
                child: PageView.builder(
              controller: _pageController,
              itemCount: total + 1,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                if (index == total) {
                  return SingleChildScrollView(
                    key: const PageStorageKey('assignment-summary'),
                    padding: const EdgeInsets.all(20),
                    child: Center(
                        child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 880),
                      child: ResultsPage(
                          team1: team1,
                          team2: team2,
                          playerPokemonMap: playerPokemonMap),
                    )),
                  );
                }
                final name = widget.players[index];
                final pokemon = playerPokemonMap[name]!;
                final theme = Theme.of(context);
                final team = index < team1.length ? 1 : 2;
                return Center(
                    child: SingleChildScrollView(
                  key: PageStorageKey('reveal-$index'),
                  padding: const EdgeInsets.all(20),
                  child: Column(children: [
                    Text('$team팀 · ${index + 1}/$total',
                        style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(name,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium),
                    const SizedBox(height: 16),
                    DecoratedBox(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: team == 1
                                ? theme.colorScheme.primaryContainer
                                : theme.colorScheme.secondaryContainer),
                        child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: PokemonPortrait(pokemon, size: 132))),
                    const SizedBox(height: 16),
                    Text(pokemon['name']!,
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    Text(pokemon['category']!,
                        style: theme.textTheme.bodyMedium),
                  ]),
                ));
              },
            )),
            Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
                child: Wrap(
                  spacing: 8,
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    TextButton(
                        onPressed: _currentPage == 0
                            ? null
                            : () =>
                                _pageController.jumpToPage(_currentPage - 1),
                        child: const Text('이전')),
                    if (_currentPage < total - 1)
                      FilledButton.tonal(
                          onPressed: () =>
                              _pageController.jumpToPage(_currentPage + 1),
                          child: const Text('다음')),
                    if (!isSummary)
                      FilledButton(
                          onPressed: () => _pageController.jumpToPage(total),
                          child: const Text('전체 결과 보기')),
                  ],
                )),
          ])),
    );
  }
}
