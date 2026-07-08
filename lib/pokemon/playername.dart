import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/player_provider.dart';
import 'pokemon_category_page.dart';

class PlayerNamePage extends ConsumerStatefulWidget {
  const PlayerNamePage({super.key});

  @override
  ConsumerState<PlayerNamePage> createState() => _PlayerNamePageState();
}

class _PlayerNamePageState extends ConsumerState<PlayerNamePage> {
  late final List<TextEditingController> _controllers;

  bool _hasValidPlayers(List<String> players) {
    final trimmedPlayers = players.map((name) => name.trim()).toList();
    return trimmedPlayers.every((name) => name.isNotEmpty) &&
        trimmedPlayers.toSet().length == trimmedPlayers.length;
  }

  List<String> _trimPlayers(List<String> players) {
    return players.map((name) => name.trim()).toList();
  }

  int _enteredPlayerCount(List<String> players) {
    return players.where((name) => name.trim().isNotEmpty).length;
  }

  bool _hasEnteredPlayers(List<String> players) {
    return _enteredPlayerCount(players) > 0;
  }

  String _helperText(List<String> players) {
    return _hasValidPlayers(players)
        ? '참가자 10명이 준비되었습니다.'
        : '중복 없는 참가자 10명을 입력해주세요.';
  }

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(10, (index) => TextEditingController());
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _clearPlayers() {
    for (final controller in _controllers) {
      controller.clear();
    }

    ref.read(playerProvider.notifier).resetPlayers();
  }

  void _goToCategoryPage(List<String> players) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PokemonCategoryPage(players: _trimPlayers(players)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final players = ref.watch(playerProvider);
    final hasValidPlayers = _hasValidPlayers(players);
    final enteredPlayerCount = _enteredPlayerCount(players);

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
                  Text(
                    '입력 $enteredPlayerCount/10명',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _helperText(players),
                    style: hasValidPlayers
                        ? null
                        : const TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                  if (_hasEnteredPlayers(players))
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _clearPlayers,
                        child: const Text('전체 초기화'),
                      ),
                    ),
                  const SizedBox(height: 8),
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
                                  controller: _controllers[playerIndex],
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
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: hasValidPlayers
                          ? () => _goToCategoryPage(players)
                          : null,
                      child: const Text('포켓몬 선택 방식 고르기'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
