import 'dart:math';
import '../data/pokemon_data.dart';

class PokemonAssignmentLogic {
  final Random _random = Random();

  List<String> assignTeams(List<String> players, int teamSize) {
    return players.sublist(0, teamSize);
  }

  List<Map<String, String>> getFilteredPokemonList(List<String> categories) {
    return pokemonList
        .where((pokemon) => categories.contains(pokemon['category']))
        .toList();
  }

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

    for (String category in selectedCategories) {
      List<Map<String, String>> categoryPokemonList =
      pokemonList.where((pokemon) => pokemon['category'] == category).toList();

      if (categoryPokemonList.isNotEmpty) {
        team1PokemonList.add(getRandomPokemon(categoryPokemonList));
        team2PokemonList.add(getRandomPokemon(categoryPokemonList));
      }
    }

    final resultMap = assignPokemonToTeams(
      team1: team1,
      team2: team2,
      team1PokemonList: team1PokemonList,
      team2PokemonList: team2PokemonList,
    );

    playerPokemonMap.addAll(resultMap);
  }

  void assignPokemonFromSelectedCategories({
    required List<String> selectedCategories,
    required List<String> team1,
    required List<String> team2,
    required Map<String, Map<String, String>> playerPokemonMap,
  }) {
    final filteredPokemonList = getFilteredPokemonList(selectedCategories);
    final List<Map<String, String>> team1PokemonList = List.from(filteredPokemonList);
    final List<Map<String, String>> team2PokemonList = List.from(filteredPokemonList);

    final List<Map<String, String>> team1SelectedPokemon = [];
    final List<Map<String, String>> team2SelectedPokemon = [];

    for (int i = 0; i < 5; i++) {
      Map<String, String> pokemon = getRandomPokemon(team1PokemonList);
      team1SelectedPokemon.add(pokemon);
      team1PokemonList.remove(pokemon);
    }

    for (int i = 0; i < 5; i++) {
      Map<String, String> pokemon = getRandomPokemon(team2PokemonList);
      team2SelectedPokemon.add(pokemon);
      team2PokemonList.remove(pokemon);
    }

    final resultMap = assignPokemonToTeams(
      team1: team1,
      team2: team2,
      team1PokemonList: team1SelectedPokemon,
      team2PokemonList: team2SelectedPokemon,
    );

    playerPokemonMap.addAll(resultMap);
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

    final List<Map<String, String>> team1PokemonList = List.from(filteredPokemonList);
    final List<Map<String, String>> team2PokemonList = List.from(filteredPokemonList);

    final List<Map<String, String>> team1SelectedPokemon = [];
    final List<Map<String, String>> team2SelectedPokemon = [];

    for (int i = 0; i < 5; i++) {
      Map<String, String> pokemon = getRandomPokemon(team1PokemonList);
      team1SelectedPokemon.add(pokemon);
      team1PokemonList.remove(pokemon);
    }

    for (int i = 0; i < 5; i++) {
      Map<String, String> pokemon = getRandomPokemon(team2PokemonList);
      team2SelectedPokemon.add(pokemon);
      team2PokemonList.remove(pokemon);
    }

    final resultMap = assignPokemonToTeams(
      team1: team1,
      team2: team2,
      team1PokemonList: List.from(team1SelectedPokemon),
      team2PokemonList: List.from(team2SelectedPokemon),
    );

    playerPokemonMap.addAll(resultMap);
  }
}
