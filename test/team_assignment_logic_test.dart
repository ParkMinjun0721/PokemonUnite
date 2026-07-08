import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pokemonbattle/team/team_assignment_logic.dart';

void main() {
  const players = ['p1', 'p2', 'p3', 'p4', 'p5', 'p6', 'p7', 'p8', 'p9', 'p10'];

  test('assigns ten players into two teams of five', () {
    final logic = TeamAssignmentLogic(random: Random(1));

    final result = logic.assignTeams(players);
    final assignedPlayers = [...result.team1, ...result.team2];

    expect(result.team1, hasLength(5));
    expect(result.team2, hasLength(5));
    expect(assignedPlayers.toSet(), hasLength(players.length));
    expect(assignedPlayers, containsAll(players));
  });

  test('rejects blank or duplicate players', () {
    final logic = TeamAssignmentLogic();

    expect(
      () => logic.assignTeams(['p1', 'p1', 'p3']),
      throwsA(isA<TeamAssignmentException>()),
    );
    expect(
      logic.hasValidPlayers(
          ['p1', ' ', 'p3', 'p4', 'p5', 'p6', 'p7', 'p8', 'p9', 'p10']),
      isFalse,
    );
  });
}
