import 'package:flutter/material.dart';
import 'package:pokemonbattle/pokemon/playername.dart';
import 'package:pokemonbattle/team/teamassign.dart';
import 'package:pokemonbattle/widgets/app_action_tile.dart';

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
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 220),
                        child: Image.asset(
                          'images/suzy3.jpeg',
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '내전 준비',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '참가자 10명 기준으로 팀과 포켓몬 배정을 준비합니다.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(
                          avatar: Icon(Icons.groups, size: 18),
                          label: Text('10명 기준'),
                        ),
                        Chip(
                          avatar: Icon(Icons.shuffle, size: 18),
                          label: Text('랜덤 배정'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    AppActionTile(
                      icon: Icons.groups,
                      title: '팀 랜덤 배정',
                      description: '참가자를 1팀과 2팀으로 나눕니다.',
                      iconSize: 28,
                      padding: const EdgeInsets.all(16.0),
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
                    AppActionTile(
                      icon: Icons.catching_pokemon,
                      title: '포켓몬 랜덤 선택',
                      description: '팀별 참가자에게 포켓몬을 배정합니다.',
                      iconSize: 28,
                      padding: const EdgeInsets.all(16.0),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PlayerNamePage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    SelectableText(
                      'Made by 님블 · 문의: pmjunasd@gmail.com',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
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
}
