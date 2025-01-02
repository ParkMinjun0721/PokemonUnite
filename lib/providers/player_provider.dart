import 'package:flutter_riverpod/flutter_riverpod.dart';

final playerProvider = StateNotifierProvider<PlayerNotifier, List<String>>((ref) {
  return PlayerNotifier();
});

class PlayerNotifier extends StateNotifier<List<String>> {
  PlayerNotifier() : super(List.filled(10, ''));

  void updatePlayer(int index, String name) {
    state = [...state]..[index] = name;
  }

  void resetPlayers() {
    state = List.filled(10, '');
  }
}
