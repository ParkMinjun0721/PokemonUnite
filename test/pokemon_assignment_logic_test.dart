import 'package:flutter_test/flutter_test.dart';
import 'package:pokemonbattle/data/pokemon_data.dart';
import 'package:pokemonbattle/pokemon/pokemon_assignment_logic.dart';

void main() {
  const team1 = ['p1', 'p2', 'p3', 'p4', 'p5'];
  const team2 = ['p6', 'p7', 'p8', 'p9', 'p10'];

  test('excludes pokemon from random category assignment', () {
    final logic = PokemonAssignmentLogic();
    final playerPokemonMap = <String, Map<String, String>>{};

    logic.assignPokemonFromSelectedCategories(
      selectedCategories: const ['어택형'],
      team1: team1,
      team2: team2,
      playerPokemonMap: playerPokemonMap,
      excludedPokemon: const ['라우드본'],
    );

    expect(playerPokemonMap.length, 10);
    expect(
      playerPokemonMap.values.map((pokemon) => pokemon['name']),
      isNot(contains('라우드본')),
    );
  });

  test('throws when exclusions leave fewer than five assignable pokemon', () {
    final logic = PokemonAssignmentLogic();
    final speedPokemon = pokemonList
        .where((pokemon) => pokemon['category'] == '스피드형')
        .map((pokemon) => pokemon['name']!)
        .toList();
    final excludedPokemon = speedPokemon.sublist(0, speedPokemon.length - 4);
    final playerPokemonMap = <String, Map<String, String>>{};

    expect(
      () => logic.assignPokemonFromSelectedCategories(
        selectedCategories: const ['스피드형'],
        team1: team1,
        team2: team2,
        playerPokemonMap: playerPokemonMap,
        excludedPokemon: excludedPokemon,
      ),
      throwsA(isA<PokemonAssignmentException>()),
    );
  });
}
