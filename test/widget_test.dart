import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pokemonbattle/main.dart';
import 'package:pokemonbattle/pokemon/pokemon_category_page.dart';
import 'package:pokemonbattle/team/team_result_page.dart';

void main() {
  testWidgets('shows home actions', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    expect(find.text('포켓몬 유나이트 내전 프로그램'), findsOneWidget);
    expect(find.text('팀 랜덤 배정'), findsOneWidget);
    expect(find.text('포켓몬 랜덤 선택'), findsOneWidget);
  });

  testWidgets('uses all pokemon categories when none are selected', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MyAppForTest(
          child: PokemonCategoryPage(
            players: [
              'p1',
              'p2',
              'p3',
              'p4',
              'p5',
              'p6',
              'p7',
              'p8',
              'p9',
              'p10'
            ],
          ),
        ),
      ),
    );

    expect(find.text('선택 없음 · 전체 포지션 사용'), findsOneWidget);
    expect(find.text('전체 카테고리에서 랜덤 배정'), findsOneWidget);
  });

  testWidgets('can select and clear all pokemon categories', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MyAppForTest(
          child: PokemonCategoryPage(
            players: [
              'p1',
              'p2',
              'p3',
              'p4',
              'p5',
              'p6',
              'p7',
              'p8',
              'p9',
              'p10'
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('전체 선택'));
    await tester.pump();

    expect(find.text('선택 5개'), findsOneWidget);
    expect(find.text('선택된 카테고리에서 랜덤 배정'), findsOneWidget);

    await tester.tap(find.text('전체 해제'));
    await tester.pump();

    expect(find.text('선택 없음 · 전체 포지션 사용'), findsOneWidget);
    expect(find.text('전체 카테고리에서 랜덤 배정'), findsOneWidget);
  });

  testWidgets('shows team assignment error for invalid player list', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MyAppForTest(child: TeamResultPage(players: ['p1', 'p2'])),
      ),
    );

    expect(find.text('팀 배정을 위해 중복 없는 참가자 10명이 필요합니다.'), findsOneWidget);
    expect(find.text('이전으로'), findsOneWidget);
  });
}

class MyAppForTest extends StatelessWidget {
  final Widget child;

  const MyAppForTest({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: child);
  }
}
