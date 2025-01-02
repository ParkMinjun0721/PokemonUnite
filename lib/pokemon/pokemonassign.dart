import 'dart:math';
import 'package:flutter/material.dart';
import '../data/pokemon_data.dart';
import 'result_page.dart';

class PokemonAssignmentPage extends StatefulWidget {
  final List<String> players;
  final List<String> selectedCategories; // 선택된 카테고리 목록
  final bool assignOneFromEach; // 각 포지션에서 한 마리씩 배정 여부

  PokemonAssignmentPage({
    required this.players,
    required this.selectedCategories,
    this.assignOneFromEach = false, // 기본값은 false
  });

  @override
  _PokemonAssignmentPageState createState() => _PokemonAssignmentPageState();
}

class _PokemonAssignmentPageState extends State<PokemonAssignmentPage> {
  final Random _random = Random();
  late PageController _pageController;

  Map<String, Map<String, String>> playerPokemonMap = {};
  List<String> team1 = [];
  List<String> team2 = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        assignTeams();
        if (widget.assignOneFromEach) {
          assignOnePokemonFromEachCategory();
        } else {
          assignPokemonFromSelectedCategories();
        }
      });
    });
  }


  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void assignTeams() {
    team1 = widget.players.sublist(0, 5);
    team2 = widget.players.sublist(5, 10);
  }

  void assignOnePokemonFromEachCategory() {
    List<Map<String, String>> team1PokemonList = [];
    List<Map<String, String>> team2PokemonList = [];

    for (String category in widget.selectedCategories) {
      List<Map<String, String>> categoryPokemonList =
      pokemonList.where((pokemon) => pokemon['category'] == category).toList();

      if (categoryPokemonList.isNotEmpty) {
        team1PokemonList.add(_getRandomPokemon(categoryPokemonList));
        team2PokemonList.add(_getRandomPokemon(categoryPokemonList));
      }
    }

    assignToTeams(team1PokemonList, team2PokemonList);
  }

  void assignPokemonFromSelectedCategories() {
    // 선택된 카테고리의 포켓몬 필터링
    List<Map<String, String>> filteredPokemonList = pokemonList
        .where((pokemon) => widget.selectedCategories.contains(pokemon['category']))
        .toList();

    // 팀별 리스트 복제
    List<Map<String, String>> team1PokemonList = List.from(filteredPokemonList);

    List<Map<String, String>> team2PokemonList = List.from(filteredPokemonList);

    // 팀 1과 팀 2에 각각 5마리씩 랜덤 배정
    List<Map<String, String>> team1SelectedPokemon = [];
    List<Map<String, String>> team2SelectedPokemon = [];

    for (int i = 0; i < 5; i++) {
      Map<String, String> pokemon = _getRandomPokemon(team1PokemonList);
      team1SelectedPokemon.add(pokemon);
      team1PokemonList.remove(pokemon);
      print('Filtered Pokemon Names: ${filteredPokemonList.map((pokemon) => pokemon['name']).toList()}');
      print('team1SelectedPokemon Names: ${team1SelectedPokemon.map((pokemon) => pokemon['name']).toList()}');
      print('team1PokemonList Names: ${team1PokemonList.map((pokemon) => pokemon['name']).toList()}\n');
    }

    for (int i = 0; i < 5; i++) {
      Map<String, String> pokemon = _getRandomPokemon(team2PokemonList);
      team2SelectedPokemon.add(pokemon);
      team2PokemonList.remove(pokemon);
      print('Filtered Pokemon Names: ${filteredPokemonList.map((pokemon) => pokemon['name']).toList()}');
      print('team2SelectedPokemon Names: ${team2SelectedPokemon.map((pokemon) => pokemon['name']).toList()}');
      print('team2PokemonList Names: ${team2PokemonList.map((pokemon) => pokemon['name']).toList()}\n');
    }

    assignToTeams(team1SelectedPokemon, team2SelectedPokemon);
  }

  void assignToTeams(List<Map<String, String>> team1PokemonList, List<Map<String, String>> team2PokemonList) {
    // 팀 1의 플레이어 순서를 랜덤으로 섞음
    team1.shuffle();
    // 팀 2의 플레이어 순서를 랜덤으로 섞음
    team2.shuffle();

    // 1팀에 포켓몬 배정
    for (int i = 0; i < team1.length; i++) {
      if (team1PokemonList.isNotEmpty) {
        playerPokemonMap[team1[i]] = team1PokemonList.removeAt(0);
      }
    }

    // 2팀에 포켓몬 배정
    for (int i = 0; i < team2.length; i++) {
      if (team2PokemonList.isNotEmpty) {
        playerPokemonMap[team2[i]] = team2PokemonList.removeAt(0);
      }
    }

    setState(() {});
  }


  Map<String, String> _getRandomPokemon(List<Map<String, String>> availablePokemonList) {
    return availablePokemonList[_random.nextInt(availablePokemonList.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.players.length + 1,
        itemBuilder: (context, index) {
          if (index == widget.players.length) {
            return ResultsPage(playerPokemonMap: playerPokemonMap, team1: team1, team2: team2);
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
            SizedBox(height: 20),
            if (pokemon != null)
              Column(
                children: [
                  Text('${pokemon['name']}이(가) 배정되었습니다!', style: TextStyle(fontSize: 20)),
                  SizedBox(height: 20),
                  Image.asset(pokemon['image'] ?? '', height: 200),
                ],
              ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (_pageController.hasClients && _pageController.page != null && _pageController.page! > 0)
                  ElevatedButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Text('이전'),
                  ),
                ElevatedButton(
                  onPressed: () {
                    if (_pageController.hasClients) {
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Text('다음'),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
