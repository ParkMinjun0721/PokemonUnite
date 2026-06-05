import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/player_provider.dart';
import 'pokemon_category_page.dart';

class PlayerNamePage extends ConsumerWidget {
  const PlayerNamePage({super.key});

  bool _hasValidPlayers(List<String> players) {
    final trimmedPlayers = players.map((name) => name.trim()).toList();
    return trimmedPlayers.every((name) => name.isNotEmpty) &&
        trimmedPlayers.toSet().length == trimmedPlayers.length;
  }

  List<String> _trimPlayers(List<String> players) {
    return players.map((name) => name.trim()).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final players = ref.watch(playerProvider);
    final hasValidPlayers = _hasValidPlayers(players);

    return Scaffold(
      appBar: AppBar(title: const Text('플레이어 이름 입력')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 600, // 웹에서도 전체 화면 크기를 600px로 제한
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (int team = 0; team < 2; team++)
                        Expanded(
                          child: Column(
                            children: List.generate(5, (index) {
                              int playerIndex = team * 5 + index;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 16,
                                ),
                                child: TextField(
                                  onChanged: (value) => ref
                                      .read(playerProvider.notifier)
                                      .updatePlayer(playerIndex, value),
                                  decoration: InputDecoration(
                                    hintText:
                                        '${team + 1}팀 참가자 ${index + 1} 이름 입력',
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                    ],
                  ),
                  if (players.any((name) => name.trim().isNotEmpty) &&
                      !hasValidPlayers)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        '이름은 공백 없이 입력하고, 중복되지 않아야 합니다.',
                        style: TextStyle(color: Colors.redAccent),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: hasValidPlayers
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PokemonCategoryPage(players: _trimPlayers(players)),
                  ),
                );
              }
            : null,
        child: const Icon(Icons.navigate_next),
      ),
    );
  }
}
