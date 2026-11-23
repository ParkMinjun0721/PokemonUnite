import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokemonbattle/widgets/labeled_progress_indicator.dart';
import '../providers/player_provider.dart';
import 'pokemon_category_page.dart';

class PlayerNamePage extends ConsumerStatefulWidget {
  const PlayerNamePage({super.key});

  @override
  ConsumerState<PlayerNamePage> createState() => _PlayerNamePageState();
}

class _PlayerNamePageState extends ConsumerState<PlayerNamePage> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

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

  int _remainingPlayerCount(List<String> players) {
    return players.length - _enteredPlayerCount(players);
  }

  List<String> _duplicatedPlayers(List<String> players) {
    final seenPlayers = <String>{};
    final duplicatedPlayers = <String>{};

    for (final player
        in _trimPlayers(players).where((name) => name.isNotEmpty)) {
      if (!seenPlayers.add(player)) {
        duplicatedPlayers.add(player);
      }
    }

    return duplicatedPlayers.toList();
  }

  bool _isDuplicatedPlayerAt(List<String> players, int index) {
    final player = players[index].trim();
    if (player.isEmpty) {
      return false;
    }

    final trimmedPlayers = _trimPlayers(players);
    return trimmedPlayers.where((name) => name == player).length > 1;
  }

  String _helperText(List<String> players) {
    final duplicatedPlayers = _duplicatedPlayers(players);

    if (_hasValidPlayers(players)) {
      return '참가자 10명이 준비되었습니다.';
    }

    if (duplicatedPlayers.isNotEmpty) {
      return '중복된 이름: ${duplicatedPlayers.join(', ')}';
    }

    if (_hasEnteredPlayers(players)) {
      return '참가자 ${_remainingPlayerCount(players)}명을 더 입력해주세요.';
    }

    return '중복 없는 참가자 10명을 입력해주세요.';
  }

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(10, (index) => TextEditingController());
    _focusNodes = List.generate(10, (index) => FocusNode());
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _clearPlayers() {
    final previousPlayers = List<String>.from(ref.read(playerProvider));

    for (final controller in _controllers) {
      controller.clear();
    }
    for (final focusNode in _focusNodes) {
      focusNode.unfocus();
    }

    ref.read(playerProvider.notifier).resetPlayers();

    if (previousPlayers.every((player) => player.trim().isEmpty)) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('참가자 입력을 모두 지웠습니다.'),
          action: SnackBarAction(
            label: '되돌리기',
            onPressed: () {
              final playerNotifier = ref.read(playerProvider.notifier);

              for (var index = 0; index < _controllers.length; index++) {
                _controllers[index].text = previousPlayers[index];
                playerNotifier.updatePlayer(index, previousPlayers[index]);
              }
            },
          ),
        ),
      );
  }

  void _clearPlayerAt(int index) {
    _controllers[index].clear();
    _focusNodes[index].requestFocus();
    ref.read(playerProvider.notifier).updatePlayer(index, '');
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

  void _handleSubmitted(int index, List<String> players) {
    if (index < _focusNodes.length - 1) {
      _focusNodes[index + 1].requestFocus();
      return;
    }

    _focusNodes[index].unfocus();
    if (_hasValidPlayers(players)) {
      _goToCategoryPage(players);
    }
  }

  @override
  Widget build(BuildContext context) {
    final players = ref.watch(playerProvider);
    final hasValidPlayers = _hasValidPlayers(players);
    final enteredPlayerCount = _enteredPlayerCount(players);
    final enteredPlayerProgress = enteredPlayerCount / players.length;

    return Scaffold(
      appBar: AppBar(title: const Text('포켓몬 배정 참가자 입력')),
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
                  const SizedBox(height: 8),
                  LabeledProgressIndicator(
                    value: enteredPlayerProgress,
                    semanticLabel: '포켓몬 배정 참가자 입력 진행률',
                    semanticValue: '$enteredPlayerCount/10명',
                  ),
                  if (_hasEnteredPlayers(players))
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _clearPlayers,
                        icon: const Icon(Icons.restart_alt),
                        label: const Text('전체 초기화'),
                      ),
                    ),
                  const SizedBox(height: 8),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final useSingleColumn = constraints.maxWidth < 520;
                      final teamSections = List.generate(
                        2,
                        (team) => _buildTeamInputSection(team),
                      );

                      if (useSingleColumn) {
                        return Column(
                          children: [
                            teamSections[0],
                            const SizedBox(height: 12),
                            teamSections[1],
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: teamSections[0]),
                          const SizedBox(width: 16),
                          Expanded(child: teamSections[1]),
                        ],
                      );
                    },
                  ),
                  if (players.any((name) => name.trim().isNotEmpty) &&
                      !hasValidPlayers)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        '이름은 빈칸 없이 입력하고, 중복되지 않아야 합니다.',
                        style: TextStyle(color: Colors.redAccent),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: hasValidPlayers
                          ? () => _goToCategoryPage(players)
                          : null,
                      icon: const Icon(Icons.catching_pokemon),
                      label: const Text('포켓몬 선택 방식 고르기'),
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

  Widget _buildTeamInputSection(int team) {
    final players = ref.watch(playerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${team + 1}팀 참가자',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...List.generate(5, (index) {
          final playerIndex = team * 5 + index;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: TextField(
              controller: _controllers[playerIndex],
              focusNode: _focusNodes[playerIndex],
              textInputAction: playerIndex == 9
                  ? TextInputAction.done
                  : TextInputAction.next,
              onSubmitted: (_) =>
                  _handleSubmitted(playerIndex, ref.read(playerProvider)),
              onChanged: (value) => ref
                  .read(playerProvider.notifier)
                  .updatePlayer(playerIndex, value),
              decoration: InputDecoration(
                labelText: '${team + 1}팀 참가자 ${index + 1}',
                hintText: '${team + 1}팀 참가자 ${index + 1} 이름 입력',
                suffixIcon: players[playerIndex].trim().isNotEmpty
                    ? IconButton(
                        tooltip: '${team + 1}팀 참가자 ${index + 1} 지우기',
                        onPressed: () => _clearPlayerAt(playerIndex),
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                errorText: _isDuplicatedPlayerAt(
                  players,
                  playerIndex,
                )
                    ? '중복된 이름'
                    : null,
              ),
            ),
          );
        }),
      ],
    );
  }
}
