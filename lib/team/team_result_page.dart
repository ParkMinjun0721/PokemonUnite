import 'package:flutter/material.dart';
import '../pokemon/pokemon_category_page.dart';
import '../pokemon/result_page.dart';
import '../widgets/match_page.dart';

class TeamResultPage extends StatefulWidget {
  const TeamResultPage({super.key, required this.players});
  final List<String> players;

  @override
  State<TeamResultPage> createState() => _TeamResultPageState();
}

class _TeamResultPageState extends State<TeamResultPage> {
  late final players = List<String>.of(widget.players)..shuffle();

  @override
  Widget build(BuildContext context) {
    return MatchPage(
      title: '팀 편성 결과',
      maxWidth: 920,
      action: FilledButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
              builder: (_) => PokemonCategoryPage(players: players)),
        ),
        child: const Text('이 팀으로 포켓몬 배정'),
      ),
      child:
          ResultsPage(team1: players.sublist(0, 5), team2: players.sublist(5)),
    );
  }
}
