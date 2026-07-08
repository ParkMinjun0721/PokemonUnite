import 'dart:math';

class TeamAssignmentException implements Exception {
  final String message;

  TeamAssignmentException(this.message);

  @override
  String toString() => message;
}

class TeamAssignmentResult {
  final List<String> team1;
  final List<String> team2;

  const TeamAssignmentResult({required this.team1, required this.team2});
}

class TeamAssignmentLogic {
  final Random _random;

  TeamAssignmentLogic({Random? random}) : _random = random ?? Random();

  bool hasValidPlayers(List<String> players) {
    final trimmedPlayers = trimPlayers(players);

    return trimmedPlayers.length == 10 &&
        trimmedPlayers.every((name) => name.isNotEmpty) &&
        trimmedPlayers.toSet().length == trimmedPlayers.length;
  }

  List<String> trimPlayers(List<String> players) {
    return players.map((name) => name.trim()).toList();
  }

  TeamAssignmentResult assignTeams(List<String> players) {
    final trimmedPlayers = trimPlayers(players);

    if (!hasValidPlayers(trimmedPlayers)) {
      throw TeamAssignmentException('팀 배정을 위해 중복 없는 참가자 10명이 필요합니다.');
    }

    final shuffledPlayers = List<String>.from(trimmedPlayers)..shuffle(_random);

    return TeamAssignmentResult(
      team1: shuffledPlayers.sublist(0, 5),
      team2: shuffledPlayers.sublist(5, 10),
    );
  }
}
