import 'dart:math';
import '../data/pokemon_data.dart';

class PokemonAssignmentException implements Exception {
  final String message;

  PokemonAssignmentException(this.message);

  @override
  String toString() => message;
}

class PokemonAssignmentLogic {
  final Random _random = Random();

  List<Map<String, String>> getFilteredPokemonList(List<String> categories) {
    return pokemonList
        .where((pokemon) => categories.contains(pokemon['category']))
        .toList();
  }

  Map<String, String> getRandomPokemon(
    List<Map<String, String>> availablePokemonList,
  ) {
    if (availablePokemonList.isEmpty) {
      throw PokemonAssignmentException('배정 가능한 포켓몬이 없습니다.');
    }

    return availablePokemonList[_random.nextInt(availablePokemonList.length)];
  }

  void assignOnePokemonFromEachCategory({
    required List<String> selectedCategories,
    required List<String> team1,
    required List<String> team2,
    required Map<String, Map<String, String>> playerPokemonMap,
  }) {
    _validateTeams(team1, team2);

    if (selectedCategories.length < team1.length) {
      throw PokemonAssignmentException('각 포지션에서 한 마리씩 배정하려면 포지션이 5개 필요합니다.');
    }

    final List<Map<String, String>> team1PokemonList = [];
    final List<Map<String, String>> team2PokemonList = [];

    // 각 카테고리에서 한 마리씩 선택
    for (String category in selectedCategories) {
      final List<Map<String, String>> categoryPokemonList = pokemonList
          .where((pokemon) => pokemon['category'] == category)
          .toList();

      if (categoryPokemonList.isEmpty) {
        throw PokemonAssignmentException('$category 포지션에 배정 가능한 포켓몬이 없습니다.');
      }

      team1PokemonList.add(getRandomPokemon(categoryPokemonList));
      team2PokemonList.add(getRandomPokemon(categoryPokemonList));
    }

    _assignSelectedPokemonToPlayers(
      players: team1,
      selectedPokemon: team1PokemonList,
      playerPokemonMap: playerPokemonMap,
    );
    _assignSelectedPokemonToPlayers(
      players: team2,
      selectedPokemon: team2PokemonList,
      playerPokemonMap: playerPokemonMap,
    );
  }

  void assignPokemonFromSelectedCategories({
    required List<String> selectedCategories,
    required List<String> team1,
    required List<String> team2,
    required Map<String, Map<String, String>> playerPokemonMap,
  }) {
    _validateTeams(team1, team2);

    final filteredPokemonList = getFilteredPokemonList(selectedCategories);
    final List<Map<String, String>> team1PokemonList = List.from(
      filteredPokemonList,
    );
    final List<Map<String, String>> team2PokemonList = List.from(
      filteredPokemonList,
    );

    final List<Map<String, String>> team1SelectedPokemon =
        _selectPokemonForTeam(team1PokemonList, team1.length);

    final List<Map<String, String>> team2SelectedPokemon =
        _selectPokemonForTeam(team2PokemonList, team2.length);

    _assignSelectedPokemonToPlayers(
      players: team1,
      selectedPokemon: team1SelectedPokemon,
      playerPokemonMap: playerPokemonMap,
    );
    _assignSelectedPokemonToPlayers(
      players: team2,
      selectedPokemon: team2SelectedPokemon,
      playerPokemonMap: playerPokemonMap,
    );
  }

  void assignPreferredPokemon({
    required List<String> preferredPokemon,
    required List<String> team1,
    required List<String> team2,
    required Map<String, Map<String, String>> playerPokemonMap,
  }) {
    _validateTeams(team1, team2);

    final List<Map<String, String>> filteredPokemonList = pokemonList
        .where((pokemon) => preferredPokemon.contains(pokemon['name']))
        .toList();

    final List<Map<String, String>> team1PokemonList = List.from(
      filteredPokemonList,
    );
    final List<Map<String, String>> team2PokemonList = List.from(
      filteredPokemonList,
    );

    final List<Map<String, String>> team1SelectedPokemon =
        _selectPokemonForTeam(team1PokemonList, team1.length);

    final List<Map<String, String>> team2SelectedPokemon =
        _selectPokemonForTeam(team2PokemonList, team2.length);

    _assignSelectedPokemonToPlayers(
      players: team1,
      selectedPokemon: team1SelectedPokemon,
      playerPokemonMap: playerPokemonMap,
    );
    _assignSelectedPokemonToPlayers(
      players: team2,
      selectedPokemon: team2SelectedPokemon,
      playerPokemonMap: playerPokemonMap,
    );
  }

  List<Map<String, String>> _selectPokemonForTeam(
    List<Map<String, String>> availablePokemonList,
    int count,
  ) {
    if (availablePokemonList.length < count) {
      throw PokemonAssignmentException(
        '배정 가능한 포켓몬이 $count마리보다 적습니다. 선택 조건을 늘려주세요.',
      );
    }

    final List<Map<String, String>> selectedPokemon = [];

    for (int i = 0; i < count; i++) {
      final pokemon = getRandomPokemon(availablePokemonList);
      selectedPokemon.add(pokemon);
      availablePokemonList.remove(pokemon);
    }

    return selectedPokemon;
  }

  void _assignSelectedPokemonToPlayers({
    required List<String> players,
    required List<Map<String, String>> selectedPokemon,
    required Map<String, Map<String, String>> playerPokemonMap,
  }) {
    if (selectedPokemon.length < players.length) {
      throw PokemonAssignmentException('플레이어 수만큼 포켓몬을 배정하지 못했습니다.');
    }

    final shuffledPlayers = List<String>.from(players)..shuffle(_random);

    for (int i = 0; i < players.length; i++) {
      playerPokemonMap[shuffledPlayers[i]] = selectedPokemon[i];
    }
  }

  void _validateTeams(List<String> team1, List<String> team2) {
    if (team1.length != 5 || team2.length != 5) {
      throw PokemonAssignmentException('각 팀은 5명이어야 합니다.');
    }
  }
}
