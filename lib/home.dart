import 'package:flutter/material.dart';
import 'package:pokemonbattle/pokemon/playername.dart';
import 'package:pokemonbattle/team/teamassign.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('포켓몬 유나이트 내전 프로그램')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset('images/suzy3.jpeg'),
                    ),
                    const SizedBox(height: 16),
                    const SelectableText(
                      '모바일 기준으로 제작했습니다.\n'
                      '핸드폰 정도의 화면 비율로 바꾸시면 쾌적하게 이용하실 수 있습니다.\n'
                      'Made by 님블\n'
                      '오류/문의 : pmjunasd@gmail.com',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    _buildActionButton(
                      context,
                      icon: Icons.groups,
                      label: '팀 랜덤 배정',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TeamAssignmentPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildActionButton(
                      context,
                      icon: Icons.catching_pokemon,
                      label: '포켓몬 랜덤 선택',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PlayerNamePage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}
