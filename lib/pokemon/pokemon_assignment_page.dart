import 'package:flutter/material.dart';
import 'pokemon_assignment_logic.dart';
import 'result_page.dart';

class PokemonAssignmentPage extends StatefulWidget {
  final List<String> players;
  final List<String> selectedCategories;
  final List<String> preferredPokemon;
  final bool assignOneFromEach;

  PokemonAssignmentPage({
    required this.players,
    required this.selectedCategories,
    this.preferredPokemon = const [],
    this.assignOneFromEach = false,
  });

  @override
  _PokemonAssignmentPageState createState() => _PokemonAssignmentPageState();
}

class _PokemonAssignmentPageState extends State<PokemonAssignmentPage> {
  late final PokemonAssignmentLogic logic;
  late Map<String, Map<String, String>> playerPokemonMap;
  late List<String> team1;
  late List<String> team2;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    logic = PokemonAssignmentLogic();
    playerPokemonMap = {};
    team1 = widget.players.sublist(0, 5);
    team2 = widget.players.sublist(5, 10);

    WidgetsBinding.instance.addPostFrameCallback((_) {
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

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('포켓몬 할당')),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 400, // 본문 내용을 400px로 제한
          ),
          child: Column(
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
                      );
                    } else {
                      return buildPlayerPage(widget.players[index]);
                    }
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 120, // 버튼 너비를 고정
                      height: 50, // 버튼 높이를 고정
                      child: ElevatedButton(
                        onPressed: _currentPage > 0
                            ? () {
                          _pageController.jumpToPage(_currentPage - 1);
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10), // 둥근 모서리
                          ),
                          textStyle: TextStyle(
                            fontSize: 16, // 텍스트 크기
                            fontWeight: FontWeight.bold, // 텍스트 굵기
                          ),
                        ),
                        child: Text('이전'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 120, // 버튼 너비를 고정
                      height: 50, // 버튼 높이를 고정
                      child: ElevatedButton(
                        onPressed: _currentPage < widget.players.length
                            ? () {
                          _pageController.jumpToPage(_currentPage + 1);
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10), // 둥근 모서리
                          ),
                          textStyle: TextStyle(
                            fontSize: 16, // 텍스트 크기
                            fontWeight: FontWeight.bold, // 텍스트 굵기
                          ),
                        ),
                        child: Text('다음'),
                      ),
                    ),
                  )

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPlayerPage(String player) {
    final pokemon = playerPokemonMap[player];
    final teamNumber = team1.contains(player) ? 1 : 2;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$player', style: TextStyle(fontSize: 28, color: Colors.green)),
          if (pokemon != null)
            Column(
              children: [
                Text('${pokemon['name']}이(가) 배정되었습니다!', style: TextStyle(fontSize: 20)),
                Image.asset(pokemon['image'] ?? '', height: 200),
              ],
            ),
        ],
      ),
    );
  }
}
