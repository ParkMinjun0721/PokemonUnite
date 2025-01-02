import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/player_provider.dart';
import 'pokemon_category_page.dart';

class PlayerNamePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final players = ref.watch(playerProvider);
    return Scaffold(
      appBar: AppBar(title: Text('플레이어 이름 입력')),
      body: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (int team = 0; team < 2; team++)
              Expanded(
                child: Column(
                  children: List.generate(5, (index) {
                    int playerIndex = team * 5 + index;
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(8,8,8,8),
                      child: TextField(
                        onChanged: (value) =>
                            ref.read(playerProvider.notifier).updatePlayer(playerIndex, value),
                        decoration: InputDecoration(
                          hintText: '${team + 1}팀 참가자 ${index + 1} 이름 입력',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: players.every((name) => name.isNotEmpty)
            ? () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PokemonCategoryPage(players: players),
            ),
          );
        }
            : null,
        child: Icon(Icons.navigate_next),
      ),
    );
  }
}
