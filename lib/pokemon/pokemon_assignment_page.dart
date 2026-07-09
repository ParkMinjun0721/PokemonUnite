import 'package:flutter/material.dart';
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
    setState(_assignPokemon);
    _pageController.jumpToPage(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('포켓몬 할당')),
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
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: OutlinedButton(
                    onPressed: _currentPage > 0
                        ? () {
                            _pageController.jumpToPage(_currentPage - 1);
                          }
                        : null,
                    child: const Text('이전'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      _pageController.jumpToPage(_currentPage + 1);
                    },
                    child: Text(_nextButtonLabel),
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
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(
            assignmentError ?? '포켓몬 배정에 실패했습니다.',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            '선택한 포켓몬이나 카테고리를 늘린 뒤 다시 시도해주세요.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('이전으로'),
          ),
        ],
      ),
    );
  }

  Widget buildPlayerPage(String player) {
    final pokemon = playerPokemonMap[player];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            player,
            style: const TextStyle(fontSize: 28, color: Colors.green),
          ),
          if (pokemon != null)
            Column(
              children: [
                Text(
                  '${pokemon['name']}이(가) 배정되었습니다!',
                  style: const TextStyle(fontSize: 20),
                ),
                Image.asset(pokemon['image'] ?? '', height: 200),
              ],
            ),
        ],
      ),
    );
  }
}
