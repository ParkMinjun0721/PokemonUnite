import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      body: PageView.builder(
        itemCount: widget.players.length + 1,
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
    );
  }

  Widget buildPlayerPage(String player) {
    final pokemon = playerPokemonMap[player];
    final teamNumber = team1.contains(player) ? 1 : 2;

    return Scaffold(
      appBar: AppBar(title: Text('$player의 포켓몬 (팀 $teamNumber)')),
      body: Center(
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
      ),
    );
  }
}
