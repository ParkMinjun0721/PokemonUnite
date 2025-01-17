import 'dart:math';
import '../data/pokemon_data.dart';

class PokemonAssignmentLogic {
  final Random _random = Random();
  final List<String> mutuallyExclusivePokemon = ['뮤츠X', '뮤츠Y'];

  List<String> assignTeams(List<String> players, int teamSize) {
    return players.sublist(0, teamSize);
  }

  List<Map<String, String>> getFilteredPokemonList(List<String> categories) {
    return pokemonList
        .where((pokemon) => categories.contains(pokemon['category']))
        .toList();
  }

  // 랜덤으로 뽑은 포켓몬들을 랜덤 팀원들에게 제공
  Map<String, Map<String, String>> assignPokemonToTeams({
    required List<String> team1,
    required List<String> team2,
    required List<Map<String, String>> team1PokemonList,
    required List<Map<String, String>> team2PokemonList,
  }) {
    final Map<String, Map<String, String>> playerPokemonMap = {};

    team1.shuffle();
    team2.shuffle();

    for (int i = 0; i < team1.length; i++) {
      if (team1PokemonList.isNotEmpty) {
        playerPokemonMap[team1[i]] = team1PokemonList.removeAt(0);
      }
    }

    for (int i = 0; i < team2.length; i++) {
      if (team2PokemonList.isNotEmpty) {
        playerPokemonMap[team2[i]] = team2PokemonList.removeAt(0);
      }
    }

    return playerPokemonMap;
  }

  Map<String, String> getRandomPokemon(List<Map<String, String>> availablePokemonList) {
    return availablePokemonList[_random.nextInt(availablePokemonList.length)];
  }

  void assignOnePokemonFromEachCategory({
    required List<String> selectedCategories,
    required List<String> team1,
    required List<String> team2,
    required Map<String, Map<String, String>> playerPokemonMap,
  }) {
    final List<Map<String, String>> team1PokemonList = [];
    final List<Map<String, String>> team2PokemonList = [];

    // 각 카테고리에서 한 마리씩 선택
    for (String category in selectedCategories) {
      List<Map<String, String>> categoryPokemonList =
      pokemonList.where((pokemon) => pokemon['category'] == category).toList();

      if (categoryPokemonList.isNotEmpty) {
        team1PokemonList.add(getRandomPokemon(categoryPokemonList));
        team2PokemonList.add(getRandomPokemon(categoryPokemonList));
      }
    }

    // 팀별 포켓몬 선택
    final List<Map<String, String>> team1SelectedPokemon = _selectPokemonForTeam(
      team1PokemonList,
      team1,
    );

    final List<Map<String, String>> team2SelectedPokemon = _selectPokemonForTeam(
      team2PokemonList,
      team2,
    );

    // 결과 저장
    for (int i = 0; i < 5; i++) {
      playerPokemonMap[team1[i]] = team1SelectedPokemon[i];
      playerPokemonMap[team2[i]] = team2SelectedPokemon[i];
    }
  }

  void assignPokemonFromSelectedCategories({
    required List<String> selectedCategories,
    required List<String> team1,
    required List<String> team2,
    required Map<String, Map<String, String>> playerPokemonMap,
  }) {
    final filteredPokemonList = getFilteredPokemonList(selectedCategories);

    // 팀별 포켓몬 리스트
    final List<Map<String, String>> team1PokemonList = List.from(filteredPokemonList);
    final List<Map<String, String>> team2PokemonList = List.from(filteredPokemonList);

    // 팀 1 포켓몬 할당
    final List<Map<String, String>> team1SelectedPokemon = _selectPokemonForTeam(
      team1PokemonList,
      team1,
    );

    // 팀 2 포켓몬 할당
    final List<Map<String, String>> team2SelectedPokemon = _selectPokemonForTeam(
      team2PokemonList,
      team2,
    );

    // 결과 저장
    for (int i = 0; i < 5; i++) {
      playerPokemonMap[team1[i]] = team1SelectedPokemon[i];
      playerPokemonMap[team2[i]] = team2SelectedPokemon[i];
    }
  }

  void assignPreferredPokemon({
    required List<String> preferredPokemon,
    required List<String> team1,
    required List<String> team2,
    required Map<String, Map<String, String>> playerPokemonMap,
  }) {
    final List<Map<String, String>> filteredPokemonList = pokemonList
        .where((pokemon) => preferredPokemon.contains(pokemon['name']))
        .toList();

    // 팀별 포켓몬 리스트
    final List<Map<String, String>> team1PokemonList = List.from(filteredPokemonList);
    final List<Map<String, String>> team2PokemonList = List.from(filteredPokemonList);

    // 팀별 포켓몬 선택
    final List<Map<String, String>> team1SelectedPokemon = _selectPokemonForTeam(
      team1PokemonList,
      team1,
    );

    final List<Map<String, String>> team2SelectedPokemon = _selectPokemonForTeam(
      team2PokemonList,
      team2,
    );

    // 결과 저장
    for (int i = 0; i < 5; i++) {
      playerPokemonMap[team1[i]] = team1SelectedPokemon[i];
      playerPokemonMap[team2[i]] = team2SelectedPokemon[i];
    }
  }

  List<Map<String, String>> _selectPokemonForTeam(
      List<Map<String, String>> availablePokemonList,
      List<String> team,
      ) {
    final List<Map<String, String>> selectedPokemon = [];

    // 포켓몬 5개 선택
    for (int i = 0; i < 5; i++) {
      final pokemon = getRandomPokemon(availablePokemonList);
      selectedPokemon.add(pokemon);
      availablePokemonList.remove(pokemon);
    }

    // 뮤츠 X와 뮤츠 Y가 같은 팀에 있는지 검사
    _ensureExclusivePokemon(selectedPokemon, availablePokemonList);

    return selectedPokemon;
  }

  void _ensureExclusivePokemon(
      List<Map<String, String>> selectedPokemon,
      List<Map<String, String>> availablePokemonList,
      ) {
    // 선택된 포켓몬 이름 리스트
    final selectedNames = selectedPokemon.map((p) => p['name']).toList();

    // 뮤츠 X와 뮤츠 Y가 동시에 있는지 확인
    final hasMutualConflict = mutuallyExclusivePokemon
        .where((name) => selectedNames.contains(name))
        .length > 1;

    if (hasMutualConflict) {
      // 충돌이 발생한 경우
      final conflictedPokemon = selectedPokemon.firstWhere(
            (p) => mutuallyExclusivePokemon.contains(p['name']),
      );

      // 충돌 포켓몬 제거
      selectedPokemon.remove(conflictedPokemon);

      // 대체 포켓몬 선택
      Map<String, String> replacement;
      do {
        replacement = getRandomPokemon(availablePokemonList);
      } while (mutuallyExclusivePokemon.contains(replacement['name']));

      // 대체 포켓몬 추가
      selectedPokemon.add(replacement);
      availablePokemonList.remove(replacement);
    }
  }
}

