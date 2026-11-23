import 'package:flutter/material.dart';

class ResultsPage extends StatefulWidget {
  final Map<String, Map<String, String>> playerPokemonMap;
  final List<String> team1;
  final List<String> team2;
  final VoidCallback? onReroll;
  final VoidCallback? onBackToSettings;

  const ResultsPage({
    super.key,
    required this.playerPokemonMap,
    required this.team1,
    required this.team2,
    this.onReroll,
    this.onBackToSettings,
  });

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  void _handleReroll() {
    widget.onReroll?.call();
    _scrollToTop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 400, // 화면 크기를 400px로 제한
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Text(
                  '총 ${widget.team1.length + widget.team2.length}명 배정 완료',
                  style: Theme.of(
                    context,
                  )
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    _buildTeamHeader('1팀', widget.team1.length),
                    ...widget.team1.indexed.map(
                      (entry) =>
                          _buildResultTile(context, '1팀', entry.$2, entry.$1),
                    ),
                    const SizedBox(height: 20),
                    _buildTeamHeader('2팀', widget.team2.length),
                    ...widget.team2.indexed.map(
                      (entry) =>
                          _buildResultTile(context, '2팀', entry.$2, entry.$1),
                    ),
                  ],
                ),
              ),
              if (widget.onReroll != null || widget.onBackToSettings != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: [
                      if (widget.onReroll != null)
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _handleReroll,
                            icon: const Icon(Icons.casino),
                            label: const Text('다시 배정하고 확인'),
                          ),
                        ),
                      if (widget.onReroll != null &&
                          widget.onBackToSettings != null)
                        const SizedBox(height: 12),
                      if (widget.onBackToSettings != null)
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: widget.onBackToSettings,
                            icon: const Icon(Icons.tune),
                            label: const Text('설정으로 돌아가기'),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamHeader(String teamName, int memberCount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(Icons.groups, size: 22),
          const SizedBox(width: 8),
          Text(
            '$teamName $memberCount명',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildResultTile(
    BuildContext context,
    String teamName,
    String player,
    int index,
  ) {
    final pokemon = widget.playerPokemonMap[player];
    final pokemonName = pokemon?['name'] ?? '배정 없음';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        title: Text(player),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$teamName ${index + 1}번 참가자'),
            const Text('배정 포켓몬'),
            Text(
              pokemonName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        leading: pokemon?['image'] != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  pokemon?['image'] ?? '',
                  width: 44,
                  height: 44,
                  fit: BoxFit.contain,
                  semanticLabel: '$pokemonName 이미지',
                ),
              )
            : CircleAvatar(
                radius: 14,
                child: Text('${index + 1}'),
              ),
        trailing: pokemon?['image'] != null
            ? CircleAvatar(
                radius: 14,
                child: Text('${index + 1}'),
              )
            : null,
      ),
    );
  }
}
