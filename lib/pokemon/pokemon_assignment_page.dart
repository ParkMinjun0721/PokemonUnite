import 'package:flutter/material.dart';
import 'package:pokemonbattle/widgets/assignment_error_view.dart';
import 'package:pokemonbattle/widgets/assignment_summary_box.dart';
import 'package:pokemonbattle/widgets/labeled_progress_indicator.dart';
import 'pokemon_assignment_logic.dart';
import 'result_page.dart';

class PokemonAssignmentPage extends StatefulWidget {
  final List<String> players;
  final List<String> selectedCategories;
  final List<String> preferredPokemon;
  final List<String> excludedPokemon;
  final bool assignOneFromEach;

  const PokemonAssignmentPage({
    super.key,
    required this.players,
    required this.selectedCategories,
    this.preferredPokemon = const [],
    this.excludedPokemon = const [],
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

  bool get _isResultPage => _currentPage == widget.players.length;

  String get _progressText => _isResultPage
      ? '결과'
      : '${_currentPage + 1}/${widget.players.length}명 확인 중';

  String get _nextButtonLabel =>
      _currentPage == widget.players.length - 1 ? '결과 보기' : '다음';

  IconData get _nextButtonIcon => _currentPage == widget.players.length - 1
      ? Icons.fact_check
      : Icons.navigate_next;

  double get _progressValue => (_currentPage + 1) / widget.players.length;

  String get _assignmentSummary {
    if (widget.preferredPokemon.isNotEmpty) {
      return '선호 포켓몬 ${widget.preferredPokemon.length}마리 후보에서 배정';
    }

    if (widget.assignOneFromEach) {
      return '각 포지션에서 한 마리씩 팀마다 배정';
    }

    final categorySummary = _categorySummary(widget.selectedCategories);
    if (widget.excludedPokemon.isNotEmpty) {
      return '$categorySummary · 제외 ${widget.excludedPokemon.length}마리 적용';
    }

    return '$categorySummary 후보에서 랜덤 배정';
  }

  String _categorySummary(List<String> categories) {
    if (categories.isEmpty) {
      return '전체 포지션';
    }

    if (categories.length == 1) {
      return categories.first;
    }

    return '포지션 ${categories.length}개';
  }

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
    playerPokemonMap.clear();
    assignmentError = null;

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
          excludedPokemon: widget.excludedPokemon,
        );
      }
    } on PokemonAssignmentException catch (error) {
      assignmentError = error.message;
    }
  }

  void _rerollPokemon() {
    setState(() {
      _assignPokemon();
      _currentPage = 0;
    });
    _pageController.jumpToPage(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('포켓몬 배정 확인')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 400, // 본문 내용을 400px로 제한
          ),
          child: assignmentError == null
              ? _buildAssignmentBody()
              : _buildErrorBody(context),
        ),
      ),
    );
  }

  Widget _buildAssignmentBody() {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.players.length + 1,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              if (index == widget.players.length) {
                return ResultsPage(
                  playerPokemonMap: playerPokemonMap,
                  team1: team1,
                  team2: team2,
                  onReroll: _rerollPokemon,
                  onBackToSettings: () => Navigator.pop(context),
                );
              } else {
                return buildPlayerPage(widget.players[index]);
              }
            },
          ),
        ),
        if (!_isResultPage) _buildNavigationControls(),
      ],
    );
  }

  Widget _buildNavigationControls() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            _progressText,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          LabeledProgressIndicator(
            value: _progressValue,
            semanticLabel: '포켓몬 배정 확인 진행률',
            semanticValue: '${_currentPage + 1}/${widget.players.length}명',
          ),
          const SizedBox(height: 12),
          AssignmentSummaryBox(
            semanticLabel: '포켓몬 배정 조건',
            summary: _assignmentSummary,
            icon: Icons.tune,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _currentPage > 0
                        ? () {
                            _pageController.jumpToPage(_currentPage - 1);
                          }
                        : null,
                    icon: const Icon(Icons.navigate_before),
                    label: const Text('이전'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _pageController.jumpToPage(_currentPage + 1);
                    },
                    icon: Icon(_nextButtonIcon),
                    label: Text(_nextButtonLabel),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBody(BuildContext context) {
    return AssignmentErrorView(
      title: assignmentError ?? '포켓몬 배정에 실패했습니다.',
      message: '선택한 포켓몬이나 카테고리를 늘린 뒤 다시 시도해주세요.',
      actionLabel: '설정으로 돌아가기',
      onBack: () => Navigator.pop(context),
    );
  }

  String _teamLabelForPlayer(String player) {
    return team1.contains(player) ? '1팀' : '2팀';
  }

  int _playerNumberForPlayer(String player) {
    final team = team1.contains(player) ? team1 : team2;
    return team.indexOf(player) + 1;
  }

  Widget buildPlayerPage(String player) {
    final pokemon = playerPokemonMap[player];
    final pokemonName = pokemon?['name'];
    final pokemonImage = pokemon?['image'];
    final teamLabel = _teamLabelForPlayer(player);
    final playerNumber = _playerNumberForPlayer(player);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: SingleChildScrollView(
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        avatar: const Icon(Icons.groups, size: 18),
                        label: Text(teamLabel),
                      ),
                      Chip(
                        avatar: const Icon(Icons.person, size: 18),
                        label: Text('$playerNumber번 참가자'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    player,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '배정 포켓몬',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pokemonName != null
                        ? '$pokemonName이(가) 배정되었습니다!'
                        : '배정 대기 중입니다.',
                    style: const TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  if (pokemonImage != null)
                    Image.asset(
                      pokemonImage,
                      height: 200,
                      fit: BoxFit.contain,
                      semanticLabel: '$pokemonName 이미지',
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
