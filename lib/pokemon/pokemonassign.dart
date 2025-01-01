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
  final PageController _pageController = PageController();
  final Random _random = Random(); // 랜덤 인스턴스를 미리 생성

  Map<String, Map<String, String>> playerPokemonMap = {};
  List<String> team1 = [];
  List<String> team2 = [];

  @override
  void initState() {
    super.initState();
    assignTeams();
    if (widget.assignOneFromEach) {
      assignOnePokemonFromEachCategory();
    } else {
      assignPokemonFromSelectedCategories();
    }
  }

  // 팀을 나누는 함수
  void assignTeams() {
    team1 = widget.players.sublist(0, 5);
    team2 = widget.players.sublist(5, 10);
  }

  // 각 카테고리에서 한 마리씩 포켓몬을 배정하는 함수
  void assignOnePokemonFromEachCategory() {
    List<Map<String, String>> team1PokemonList = [];
    List<Map<String, String>> team2PokemonList = [];

    // 팀1과 팀2에 대해 별도의 리스트에서 포켓몬을 선택
    for (String category in widget.selectedCategories) {
      // 팀1을 위한 카테고리별 포켓몬 리스트
      List<Map<String, String>> team1CategoryPokemonList = pokemonList
          .where((pokemon) => pokemon['category'] == category)
          .toList();

      // 팀2를 위한 카테고리별 포켓몬 리스트
      List<Map<String, String>> team2CategoryPokemonList = pokemonList
          .where((pokemon) => pokemon['category'] == category)
          .toList();

      if (team1CategoryPokemonList.isNotEmpty && team2CategoryPokemonList.isNotEmpty) {
        // 팀1에 포켓몬 배정
        final pokemonForTeam1 = _getRandomPokemon(team1CategoryPokemonList);
        team1PokemonList.add(pokemonForTeam1);

        // 팀2에도 동일한 카테고리에서 다시 랜덤 포켓몬 배정
        final pokemonForTeam2 = _getRandomPokemon(team2CategoryPokemonList); // 중복 허용
        team2PokemonList.add(pokemonForTeam2);
      }
    }

    // 1팀과 2팀에 배정
    assignToTeams(team1PokemonList, team2PokemonList);
  }

  // 선택한 카테고리에서 포켓몬을 무작위로 선택하는 함수
  void assignPokemonFromSelectedCategories() {
    // 팀1을 위한 선택된 카테고리의 포켓몬 리스트
    List<Map<String, String>> team1FilteredPokemonList = pokemonList
        .where((pokemon) => widget.selectedCategories.contains(pokemon['category']))
        .toList();

    // 팀2를 위한 선택된 카테고리의 포켓몬 리스트
    List<Map<String, String>> team2FilteredPokemonList = pokemonList
        .where((pokemon) => widget.selectedCategories.contains(pokemon['category']))
        .toList();

    // 1팀과 2팀에 배정
    assignToTeams(team1FilteredPokemonList, team2FilteredPokemonList);
  }

  // 1팀과 2팀에 포켓몬 배정 (팀 내 중복 방지)
  void assignToTeams(List<Map<String, String>> team1PokemonList, List<Map<String, String>> team2PokemonList) {
    // 1팀에 포켓몬 할당 (팀 내부 중복 방지)
    team1.forEach((player) {
      if (team1PokemonList.isNotEmpty) {
        final pokemon = _getRandomPokemon(team1PokemonList); // 랜덤으로 포켓몬 할당
        team1PokemonList.remove(pokemon); // 팀 1 내에서 중복 방지
        playerPokemonMap[player] = pokemon;
      }
    });

    // 2팀에 포켓몬 할당 (팀 내부 중복 방지)
    team2.forEach((player) {
      if (team2PokemonList.isNotEmpty) {
        final pokemon = _getRandomPokemon(team2PokemonList); // 랜덤으로 포켓몬 할당
        team2PokemonList.remove(pokemon); // 팀 2 내에서 중복 방지
        playerPokemonMap[player] = pokemon;
      }
    });
  }

  // 랜덤으로 포켓몬을 가져오는 함수 (한 번 생성한 Random 인스턴스를 재사용)
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
            final player = widget.players[index];
            final pokemon = playerPokemonMap[player];
            final teamNumber = team1.contains(player) ? 1 : 2;
            return buildPlayerPage(player, pokemon, teamNumber, index);
          }
        },
      ),
    );
  }

  Widget buildPlayerPage(String player, Map<String, String>? pokemon, int teamNumber, int index) {
    return Scaffold(
      appBar: AppBar(title: Text('$player의 포켓몬 (팀 $teamNumber)')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('내전 $teamNumber팀\n', style: TextStyle(fontSize: 20)),
            Text('$player', style: TextStyle(fontSize: 30, color: Colors.green)),
            SizedBox(height: 10),
            Text('$player님이 플레이할 포켓몬은 ${pokemon?['name']}입니다!', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            Image.asset(pokemon?['image'] ?? '', height: 200),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (index > 0)
                  ElevatedButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Text('이전'),
                  ),
                if (index < widget.players.length - 1)
                  ElevatedButton(
                    onPressed: () {
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
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
