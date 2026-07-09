import 'package:flutter/material.dart';

class ResultsPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text('포켓몬 할당 결과')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 400, // 화면 크기를 400px로 제한
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    const Text(
                      '1팀:',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ...team1.map(_buildResultTile),
                    const SizedBox(height: 20),
                    const Text(
                      '2팀:',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ...team2.map(_buildResultTile),
                  ],
                ),
              ),
              if (onReroll != null || onBackToSettings != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: [
                      if (onReroll != null)
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: onReroll,
                            child: const Text('다시 배정'),
                          ),
                        ),
                      if (onReroll != null && onBackToSettings != null)
                        const SizedBox(height: 12),
                      if (onBackToSettings != null)
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            onPressed: onBackToSettings,
                            child: const Text('설정으로 돌아가기'),
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

  Widget _buildResultTile(String player) {
    final pokemon = playerPokemonMap[player];

    return ListTile(
      title: Text('$player: ${pokemon?['name']}'),
      leading: pokemon?['image'] != null
          ? Image.asset(pokemon?['image'] ?? '', width: 50, height: 50)
          : null,
    );
  }
}
