import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pokemonbattle/data/pokemon_data.dart';
import 'package:pokemonbattle/main.dart';
import 'package:pokemonbattle/pokemon/pokemon_assignment_page.dart';
import 'package:pokemonbattle/pokemon/pokemon_category_page.dart';
import 'package:pokemonbattle/pokemon/pokemon_exclude_page.dart';
import 'package:pokemonbattle/pokemon/playername.dart';
import 'package:pokemonbattle/pokemon/preferred_pokemon_page.dart';
import 'package:pokemonbattle/pokemon/result_page.dart';
import 'package:pokemonbattle/team/teamassign.dart';
import 'package:pokemonbattle/team/team_result_page.dart';
import 'package:pokemonbattle/theme/app_theme.dart';
import 'package:pokemonbattle/widgets/app_action_tile.dart';
import 'package:pokemonbattle/widgets/assignment_error_view.dart';
import 'package:pokemonbattle/widgets/assignment_summary_box.dart';

void main() {
  test('app theme defines shared control styles', () {
    final theme = AppTheme.lightTheme;

    expect(theme.useMaterial3, isTrue);
    expect(theme.inputDecorationTheme.filled, isTrue);
    expect(theme.elevatedButtonTheme.style, isNotNull);
    expect(theme.outlinedButtonTheme.style, isNotNull);
    expect(theme.chipTheme.shape, isNotNull);
  });

  testWidgets('app action tile exposes label and handles tap', (
    WidgetTester tester,
  ) async {
    var tapCount = 0;

    await tester.pumpWidget(
      MyAppForTest(
        child: AppActionTile(
          icon: Icons.shuffle,
          title: '테스트 액션',
          description: '테스트 설명입니다.',
          onPressed: () => tapCount++,
        ),
      ),
    );

    expect(find.text('테스트 액션'), findsOneWidget);
    expect(find.text('테스트 설명입니다.'), findsOneWidget);
    expect(find.bySemanticsLabel('테스트 액션'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('테스트 액션'));
    await tester.pump();

    expect(tapCount, 1);
  });

  testWidgets('assignment error view exposes custom recovery action', (
    WidgetTester tester,
  ) async {
    var backCount = 0;

    await tester.pumpWidget(
      MyAppForTest(
        child: AssignmentErrorView(
          title: '배정 실패',
          message: '조건을 다시 확인해주세요.',
          actionLabel: '설정으로 돌아가기',
          onBack: () => backCount++,
        ),
      ),
    );

    expect(find.text('배정 실패'), findsOneWidget);
    expect(find.text('조건을 다시 확인해주세요.'), findsOneWidget);
    expect(find.text('설정으로 돌아가기'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);

    await tester.tap(find.text('설정으로 돌아가기'));
    await tester.pump();

    expect(backCount, 1);
  });

  testWidgets('assignment summary box exposes condition summary', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MyAppForTest(
        child: AssignmentSummaryBox(
          semanticLabel: '테스트 배정 조건',
          summary: '배정 후보 5마리 · 선택한 포켓몬만 사용',
        ),
      ),
    );

    expect(find.text('배정 후보 5마리 · 선택한 포켓몬만 사용'), findsOneWidget);
    expect(find.byIcon(Icons.info_outline), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics && widget.properties.label == '테스트 배정 조건',
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows home actions', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    expect(find.text('포켓몬 유나이트 내전 프로그램'), findsOneWidget);
    expect(find.text('내전 준비'), findsOneWidget);
    expect(find.text('10명 기준'), findsOneWidget);
    expect(find.text('랜덤 배정'), findsOneWidget);
    expect(find.text('팀 랜덤 배정'), findsOneWidget);
    expect(find.bySemanticsLabel('팀 랜덤 배정'), findsOneWidget);
    expect(find.text('참가자를 1팀과 2팀으로 나눕니다.'), findsOneWidget);
    expect(find.text('포켓몬 랜덤 선택'), findsOneWidget);
    expect(find.bySemanticsLabel('포켓몬 랜덤 선택'), findsOneWidget);
    expect(find.text('팀별 참가자에게 포켓몬을 배정합니다.'), findsOneWidget);
  });

  testWidgets('startup error shows recovery action and details', (
    WidgetTester tester,
  ) async {
    var retryCount = 0;
    final retryCompleter = Completer<void>();

    await tester.pumpWidget(
      AppStartupError(
        error: Exception('env failed'),
        onRetry: () async {
          retryCount++;
          await retryCompleter.future;
        },
      ),
    );

    expect(find.text('앱 설정을 불러오지 못했습니다.'), findsOneWidget);
    expect(find.text('네트워크 상태를 확인한 뒤 다시 시도해주세요.'), findsOneWidget);
    expect(find.text('오류 상세'), findsOneWidget);
    expect(find.text('Exception: env failed'), findsOneWidget);

    await tester.tap(find.text('다시 시도'));
    await tester.pump();

    expect(retryCount, 1);
    expect(find.text('다시 시도 중'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.tap(find.text('다시 시도 중'));
    await tester.pump();

    expect(retryCount, 1);

    retryCompleter.complete();
    await tester.pump();

    expect(find.text('다시 시도'), findsOneWidget);
  });

  testWidgets('startup error keeps retry available after retry failure', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      AppStartupError(
        error: Exception('first failure'),
        onRetry: () async {
          throw Exception('retry failure');
        },
      ),
    );

    expect(find.text('Exception: first failure'), findsOneWidget);

    await tester.tap(find.text('다시 시도'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Exception: retry failure'), findsOneWidget);
    expect(find.text('다시 시도'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('home actions open assignment input pages', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    await tester.tap(find.text('팀 랜덤 배정'));
    await tester.pumpAndSettle();

    expect(find.text('팀 배정 입력'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('포켓몬 랜덤 선택'));
    await tester.pumpAndSettle();

    expect(find.text('포켓몬 배정 참가자 입력'), findsOneWidget);
  });

  testWidgets('uses all pokemon categories when none are selected', (
    WidgetTester tester,
  ) async {
    final allPokemonCount = pokemonList.length;
    final attackPokemonCount =
        pokemonList.where((pokemon) => pokemon['category'] == '어택형').length;

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

    expect(find.text('포켓몬 배정 방식 선택'), findsOneWidget);
    expect(find.text('선택 없음 · 전체 포지션 사용'), findsOneWidget);
    expect(
      find.text('랜덤 후보 $allPokemonCount마리 · 선택하지 않으면 전체 포지션 사용'),
      findsOneWidget,
    );
    expect(find.text('어택형'), findsOneWidget);
    expect(find.text('$attackPokemonCount마리 후보'), findsOneWidget);
    expect(find.byIcon(Icons.done_all), findsOneWidget);
    expect(find.byIcon(Icons.clear_all), findsOneWidget);
    expect(find.bySemanticsLabel('랜덤 후보 포켓몬 범위'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(
      tester
          .widget<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator),
          )
          .value,
      1,
    );

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pump();

    expect(find.text('배정 방식'), findsOneWidget);
    expect(find.text('전체 카테고리에서 랜덤 배정'), findsOneWidget);
    expect(find.text('전체 포지션 후보 안에서 10마리를 배정합니다.'), findsOneWidget);
    expect(find.text('각 포지션에서 한 마리씩 배정'), findsOneWidget);
    expect(
      find.text('어택형, 밸런스형, 스피드형, 디펜스형, 서포트형을 팀마다 한 마리씩 배정합니다.'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('전체 카테고리에서 랜덤 배정'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -360));
    await tester.pump();

    expect(find.text('선호 포켓몬 배정'), findsOneWidget);
    expect(find.text('직접 고른 포켓몬 후보 안에서만 배정합니다.'), findsOneWidget);
    expect(find.text('제외 포켓몬 설정 후 랜덤 배정'), findsOneWidget);
    expect(find.text('선택한 포지션 후보에서 제외할 포켓몬을 뺀 뒤 배정합니다.'), findsOneWidget);
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

    final allPokemonCount = pokemonList.length;
    final attackPokemonCount =
        pokemonList.where((pokemon) => pokemon['category'] == '어택형').length;

    await tester.tap(find.text('어택형'));
    await tester.pump();

    expect(find.text('선택 1개'), findsOneWidget);
    expect(
      find.text('랜덤 후보 $attackPokemonCount마리 · 선택한 포지션만 사용'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator),
          )
          .value,
      closeTo(attackPokemonCount / allPokemonCount, 0.001),
    );

    await tester.tap(find.text('전체 선택'));
    await tester.pump();

    expect(find.text('선택 5개'), findsOneWidget);

    await tester.tap(find.text('전체 해제'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('선택 없음 · 전체 포지션 사용'), findsOneWidget);
    expect(find.text('포지션 선택을 모두 해제했습니다.'), findsOneWidget);
    expect(find.text('되돌리기'), findsOneWidget);

    await tester.tap(find.byType(SnackBarAction));
    await tester.pump();

    expect(find.text('선택 5개'), findsOneWidget);

    await tester.tap(find.text('전체 해제'));
    await tester.pump();

    expect(find.text('선택 없음 · 전체 포지션 사용'), findsOneWidget);

    await tester.tap(find.text('어택형'));
    await tester.pump();
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pump();

    expect(find.text('선택한 포지션 후보 안에서 10마리를 배정합니다.'), findsOneWidget);
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
    expect(find.text('참가자 이름을 다시 확인해주세요.'), findsOneWidget);
    expect(find.text('입력으로 돌아가기'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });

  testWidgets('can reroll team assignment from result page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MyAppForTest(
          child: TeamResultPage(
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

    expect(find.text('1팀 5명'), findsOneWidget);
    expect(find.text('1팀 1번 참가자'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('2팀 5명'), 120);
    expect(find.text('2팀 5명'), findsOneWidget);
    expect(find.text('총 10명 배정 완료'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('2팀 1번 참가자'), 80);
    expect(find.text('2팀 1번 참가자'), findsOneWidget);
    expect(find.text('다시 배정'), findsOneWidget);
    expect(find.text('입력으로 돌아가기'), findsOneWidget);
    expect(find.byIcon(Icons.shuffle), findsOneWidget);
    expect(find.byIcon(Icons.edit), findsOneWidget);

    await tester.tap(find.text('다시 배정'));
    await tester.pump();

    expect(find.text('1팀 5명'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('2팀 5명'), 120);
    expect(find.text('2팀 5명'), findsOneWidget);
  });

  testWidgets('tracks and clears team assignment player inputs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MyAppForTest(child: TeamAssignmentPage())),
    );

    expect(find.text('입력 0/10명'), findsOneWidget);
    expect(find.text('중복 없는 참가자 10명을 입력해주세요.'), findsOneWidget);
    expect(find.text('1팀 참가자'), findsOneWidget);
    expect(find.text('2팀 참가자'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is ConstrainedBox && widget.constraints.maxWidth == 600,
      ),
      findsWidgets,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Row &&
            widget.crossAxisAlignment == CrossAxisAlignment.start,
      ),
      findsWidgets,
    );
    expect(find.text('팀 랜덤 배정'), findsOneWidget);
    expect(find.byIcon(Icons.shuffle), findsOneWidget);
    expect(find.bySemanticsLabel('팀 배정 참가자 입력 진행률'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(
      tester
          .widget<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator),
          )
          .value,
      0,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).at(0)).textInputAction,
      TextInputAction.next,
    );
    expect(
      tester
          .widget<TextField>(find.byType(TextField).at(0))
          .decoration
          ?.labelText,
      '1팀 참가자 1',
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).at(9)).textInputAction,
      TextInputAction.done,
    );
    expect(
      tester
          .widget<TextField>(find.byType(TextField).at(9))
          .decoration
          ?.labelText,
      '2팀 참가자 5',
    );

    await tester.enterText(find.byType(TextField).at(0), 'p1');
    await tester.pump();

    expect(find.text('입력 1/10명'), findsOneWidget);
    expect(find.text('참가자 9명을 더 입력해주세요.'), findsOneWidget);
    expect(find.text('이름은 빈칸 없이 입력하고, 중복되지 않아야 합니다.'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(1), 'p1');
    await tester.pump();

    expect(find.text('입력 2/10명'), findsOneWidget);
    expect(find.text('중복된 이름: p1'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byType(TextField).at(0))
          .decoration
          ?.errorText,
      '중복된 이름',
    );
    expect(
      tester
          .widget<TextField>(find.byType(TextField).at(1))
          .decoration
          ?.errorText,
      '중복된 이름',
    );
    expect(find.text('전체 초기화'), findsOneWidget);
    expect(find.byIcon(Icons.restart_alt), findsOneWidget);
    expect(find.byTooltip('1팀 참가자 1 지우기'), findsOneWidget);
    expect(find.byTooltip('1팀 참가자 2 지우기'), findsOneWidget);
    expect(
      tester
          .widget<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator),
          )
          .value,
      0.2,
    );

    await tester.tap(find.byTooltip('1팀 참가자 2 지우기'));
    await tester.pump();

    expect(find.text('입력 1/10명'), findsOneWidget);
    expect(find.text('참가자 9명을 더 입력해주세요.'), findsOneWidget);
    expect(find.text('중복된 이름: p1'), findsNothing);
    expect(find.byTooltip('1팀 참가자 2 지우기'), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField).at(1)).controller?.text,
      isEmpty,
    );

    await tester.tap(find.text('전체 초기화'));
    await tester.pump();

    expect(find.text('입력 0/10명'), findsOneWidget);
    expect(find.text('중복된 이름: p1'), findsNothing);
    expect(find.text('p1'), findsNothing);
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('참가자 입력을 모두 지웠습니다.'), findsOneWidget);
    expect(find.text('되돌리기'), findsOneWidget);

    await tester.tap(find.byType(SnackBarAction));
    await tester.pump();

    expect(find.text('입력 1/10명'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField).at(0)).controller?.text,
      'p1',
    );
  });

  testWidgets('tracks and clears pokemon assignment player inputs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MyAppForTest(child: PlayerNamePage())),
    );

    expect(find.text('포켓몬 배정 참가자 입력'), findsOneWidget);
    expect(find.text('입력 0/10명'), findsOneWidget);
    expect(find.text('중복 없는 참가자 10명을 입력해주세요.'), findsOneWidget);
    expect(find.text('1팀 참가자'), findsOneWidget);
    expect(find.text('2팀 참가자'), findsOneWidget);
    expect(find.text('포켓몬 선택 방식 고르기'), findsOneWidget);
    expect(find.byIcon(Icons.catching_pokemon), findsOneWidget);
    expect(find.bySemanticsLabel('포켓몬 배정 참가자 입력 진행률'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(
      tester
          .widget<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator),
          )
          .value,
      0,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).at(0)).textInputAction,
      TextInputAction.next,
    );
    expect(
      tester
          .widget<TextField>(find.byType(TextField).at(0))
          .decoration
          ?.labelText,
      '1팀 참가자 1',
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).at(9)).textInputAction,
      TextInputAction.done,
    );
    expect(
      tester
          .widget<TextField>(find.byType(TextField).at(9))
          .decoration
          ?.labelText,
      '2팀 참가자 5',
    );

    await tester.enterText(find.byType(TextField).at(0), 'p1');
    await tester.pump();

    expect(find.text('입력 1/10명'), findsOneWidget);
    expect(find.text('참가자 9명을 더 입력해주세요.'), findsOneWidget);
    expect(find.text('이름은 빈칸 없이 입력하고, 중복되지 않아야 합니다.'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(1), 'p1');
    await tester.pump();

    expect(find.text('입력 2/10명'), findsOneWidget);
    expect(find.text('중복된 이름: p1'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byType(TextField).at(0))
          .decoration
          ?.errorText,
      '중복된 이름',
    );
    expect(
      tester
          .widget<TextField>(find.byType(TextField).at(1))
          .decoration
          ?.errorText,
      '중복된 이름',
    );
    expect(find.text('전체 초기화'), findsOneWidget);
    expect(find.byIcon(Icons.restart_alt), findsOneWidget);
    expect(find.byTooltip('1팀 참가자 1 지우기'), findsOneWidget);
    expect(find.byTooltip('1팀 참가자 2 지우기'), findsOneWidget);
    expect(
      tester
          .widget<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator),
          )
          .value,
      0.2,
    );

    await tester.tap(find.byTooltip('1팀 참가자 2 지우기'));
    await tester.pump();

    expect(find.text('입력 1/10명'), findsOneWidget);
    expect(find.text('참가자 9명을 더 입력해주세요.'), findsOneWidget);
    expect(find.text('중복된 이름: p1'), findsNothing);
    expect(find.byTooltip('1팀 참가자 2 지우기'), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField).at(1)).controller?.text,
      isEmpty,
    );

    await tester.tap(find.text('전체 초기화'));
    await tester.pump();

    expect(find.text('입력 0/10명'), findsOneWidget);
    expect(find.text('중복된 이름: p1'), findsNothing);
    expect(find.text('p1'), findsNothing);
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('참가자 입력을 모두 지웠습니다.'), findsOneWidget);
    expect(find.text('되돌리기'), findsOneWidget);

    await tester.tap(find.byType(SnackBarAction));
    await tester.pump();

    expect(find.text('입력 1/10명'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField).at(0)).controller?.text,
      'p1',
    );
  });

  testWidgets('pokemon result page exposes reroll and settings actions', (
    WidgetTester tester,
  ) async {
    var rerollCount = 0;
    var backCount = 0;
    final team1 = List.generate(5, (index) => 'p${index + 1}');
    final team2 = List.generate(5, (index) => 'p${index + 6}');
    final playerPokemonMap = {
      for (var i = 0; i < 10; i++)
        'p${i + 1}': {
          'name': i == 1 ? '라우드본' : '피카츄',
          'image': i == 1 ? 'images/laudbone.webp' : 'images/Pikachu.png',
        },
    };

    await tester.pumpWidget(
      MyAppForTest(
        child: ResultsPage(
          playerPokemonMap: playerPokemonMap,
          team1: team1,
          team2: team2,
          onReroll: () => rerollCount++,
          onBackToSettings: () => backCount++,
        ),
      ),
    );

    expect(find.text('1팀 5명'), findsOneWidget);
    expect(find.text('총 10명 배정 완료'), findsOneWidget);
    expect(find.text('1팀 1번 참가자'), findsOneWidget);
    expect(find.text('배정 포켓몬'), findsWidgets);
    expect(find.text('피카츄'), findsWidgets);
    expect(find.text('라우드본'), findsOneWidget);
    expect(find.bySemanticsLabel('피카츄 이미지'), findsWidgets);
    expect(find.bySemanticsLabel('라우드본 이미지'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('2팀 5명'), 120);
    expect(find.text('2팀 5명'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('2팀 1번 참가자'), 80);
    expect(find.text('2팀 1번 참가자'), findsOneWidget);
    expect(find.text('다시 배정하고 확인'), findsOneWidget);
    expect(find.text('설정으로 돌아가기'), findsOneWidget);
    expect(find.byIcon(Icons.casino), findsOneWidget);
    expect(find.byIcon(Icons.tune), findsOneWidget);

    await tester.tap(find.text('다시 배정하고 확인'));
    await tester.pump();

    expect(find.text('1팀 5명'), findsOneWidget);
    expect(find.text('1팀 1번 참가자'), findsOneWidget);

    await tester.tap(find.text('설정으로 돌아가기'));

    expect(rerollCount, 1);
    expect(backCount, 1);
  });

  testWidgets('pokemon assignment page shows progress and result action', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MyAppForTest(
        child: PokemonAssignmentPage(
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
          selectedCategories: ['어택형', '밸런스형', '스피드형', '디펜스형', '서포트형'],
        ),
      ),
    );

    expect(find.text('포켓몬 배정 확인'), findsOneWidget);
    expect(find.text('1/10명 확인 중'), findsOneWidget);
    expect(find.text('1팀'), findsOneWidget);
    expect(find.text('1번 참가자'), findsOneWidget);
    expect(find.text('배정 포켓몬'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.semanticLabel != null &&
            widget.semanticLabel!.endsWith('이미지'),
      ),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('포켓몬 배정 확인 진행률'), findsOneWidget);
    expect(find.text('포지션 5개 후보에서 랜덤 배정'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics && widget.properties.label == '포켓몬 배정 조건',
      ),
      findsOneWidget,
    );
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(
      tester
          .widget<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator),
          )
          .value,
      0.1,
    );
    expect(find.text('다음'), findsOneWidget);

    for (var i = 0; i < 5; i++) {
      await tester.tap(find.text('다음'));
      await tester.pump();
    }

    expect(find.text('6/10명 확인 중'), findsOneWidget);
    expect(find.text('2팀'), findsOneWidget);
    expect(find.text('1번 참가자'), findsOneWidget);

    for (var i = 0; i < 4; i++) {
      await tester.tap(find.text('다음'));
      await tester.pump();
    }

    expect(find.text('10/10명 확인 중'), findsOneWidget);
    expect(find.text('결과 보기'), findsOneWidget);

    await tester.tap(find.text('결과 보기'));
    await tester.pump();

    expect(find.text('설정으로 돌아가기'), findsOneWidget);
    expect(find.text('다시 배정하고 확인'), findsOneWidget);
    expect(find.text('결과 보기'), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsNothing);

    await tester.tap(find.text('다시 배정하고 확인'));
    await tester.pump();

    expect(find.text('1/10명 확인 중'), findsOneWidget);
    expect(find.text('다음'), findsOneWidget);
    expect(find.bySemanticsLabel('포켓몬 배정 확인 진행률'), findsOneWidget);
  });

  testWidgets('pokemon assignment page explains active assignment conditions', (
    WidgetTester tester,
  ) async {
    final players = List.generate(10, (index) => 'p${index + 1}');
    final categories = ['어택형', '밸런스형', '스피드형', '디펜스형', '서포트형'];
    final preferredPokemon =
        pokemonList.take(5).map((pokemon) => pokemon['name'] ?? '').toList();

    await tester.pumpWidget(
      MyAppForTest(
        child: PokemonAssignmentPage(
          players: players,
          selectedCategories: categories,
          preferredPokemon: preferredPokemon,
        ),
      ),
    );

    expect(find.text('선호 포켓몬 5마리 후보에서 배정'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics && widget.properties.label == '포켓몬 배정 조건',
      ),
      findsOneWidget,
    );

    await tester.pumpWidget(
      MyAppForTest(
        child: PokemonAssignmentPage(
          players: players,
          selectedCategories: categories,
          excludedPokemon: const ['피카츄'],
        ),
      ),
    );

    expect(find.text('포지션 5개 · 제외 1마리 적용'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics && widget.properties.label == '포켓몬 배정 조건',
      ),
      findsOneWidget,
    );
  });

  testWidgets('pokemon assignment error explains recovery action', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MyAppForTest(
        child: PokemonAssignmentPage(
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
          selectedCategories: [],
          preferredPokemon: ['피카츄'],
        ),
      ),
    );

    expect(
      find.text('배정 가능한 포켓몬이 5마리보다 적습니다. 선택 조건을 늘려주세요.'),
      findsOneWidget,
    );
    expect(
      find.text('선택한 포켓몬이나 카테고리를 늘린 뒤 다시 시도해주세요.'),
      findsOneWidget,
    );
    expect(find.text('설정으로 돌아가기'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });

  testWidgets('preferred pokemon search can show and clear empty result', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MyAppForTest(
        child: PreferredPokemonPage(
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
    );

    await tester.enterText(find.byType(TextField), '없는포켓몬');
    await tester.pump();

    expect(find.text('검색 결과 0마리'), findsOneWidget);
    expect(find.text('"없는포켓몬" 검색 결과가 없습니다.'), findsOneWidget);
    expect(find.text('검색어 지우기'), findsOneWidget);

    await tester.tap(find.text('검색어 지우기'));
    await tester.pump();

    expect(find.text('"없는포켓몬" 검색 결과가 없습니다.'), findsNothing);
    expect(find.text('검색 결과 0마리'), findsNothing);
  });

  testWidgets('preferred pokemon search expands matching category', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MyAppForTest(
        child: PreferredPokemonPage(
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
    );

    await tester.enterText(find.byType(TextField), '피카츄');
    await tester.pump();

    expect(find.text('검색 결과 1마리'), findsOneWidget);
    expect(find.text('어택형 1마리'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, '피카츄'), findsOneWidget);
  });

  testWidgets('preferred pokemon selection shows minimum progress', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MyAppForTest(
        child: PreferredPokemonPage(
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
    );

    expect(find.text('선호 포켓몬을 5마리 더 선택해주세요.'), findsOneWidget);
    expect(
      find.text('포켓몬을 검색하거나 포지션을 열어 후보를 선택하세요.'),
      findsOneWidget,
    );
    expect(find.text('배정 후보 없음 · 최소 5마리 선택 필요'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics && widget.properties.label == '선호 포켓몬 배정 조건',
      ),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('선호 포켓몬 선택 진행률'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(
      tester
          .widget<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator),
          )
          .value,
      0,
    );

    for (final pokemonName in ['피카츄', '레시라무', '에이스번', '샹델라', '가디안']) {
      await tester.enterText(find.byType(TextField), pokemonName);
      await tester.pumpAndSettle();
      expect(find.text('검색 결과 1마리'), findsOneWidget);
      expect(find.text('어택형 1마리'), findsOneWidget);

      final pokemonChip = find.widgetWithText(FilterChip, pokemonName);
      await tester.ensureVisible(pokemonChip);
      await tester.pumpAndSettle();
      await tester.tap(pokemonChip);
      await tester.pumpAndSettle();
    }

    expect(find.text('선택 5마리'), findsOneWidget);
    expect(find.text('선택한 포켓몬 후보 안에서 랜덤 배정됩니다.'), findsOneWidget);
    expect(find.text('배정 후보 5마리 · 선택한 포켓몬만 사용'), findsOneWidget);
    expect(find.text('선택한 포켓몬 5마리'), findsOneWidget);
    expect(
      tester
          .widget<InputChip>(find.widgetWithText(InputChip, '피카츄'))
          .deleteButtonTooltipMessage,
      '피카츄 삭제',
    );
    expect(find.text('전체 해제'), findsOneWidget);
    expect(find.byIcon(Icons.clear_all), findsOneWidget);
    expect(find.byIcon(Icons.star), findsOneWidget);
    expect(
      tester
          .widget<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator),
          )
          .value,
      1,
    );

    await tester.tap(find.byTooltip('피카츄 삭제'));
    await tester.pumpAndSettle();

    expect(find.text('선택 4마리'), findsOneWidget);
    expect(find.text('선택한 포켓몬 4마리'), findsOneWidget);
    expect(find.text('선호 포켓몬을 1마리 더 선택해주세요.'), findsOneWidget);
    expect(find.text('배정 후보 4마리 · 선택한 포켓몬만 사용'), findsOneWidget);
    expect(find.widgetWithText(InputChip, '피카츄'), findsNothing);

    await tester.tap(find.text('전체 해제'));
    await tester.pumpAndSettle();

    expect(find.text('선택 0마리'), findsOneWidget);
    expect(find.text('선택한 포켓몬 4마리'), findsNothing);
    expect(find.text('배정 후보 없음 · 최소 5마리 선택 필요'), findsOneWidget);
    expect(find.text('선택한 포켓몬을 모두 해제했습니다.'), findsOneWidget);
    expect(find.text('되돌리기'), findsOneWidget);

    await tester.tap(find.byType(SnackBarAction));
    await tester.pump();

    expect(find.text('선택 4마리'), findsOneWidget);
    expect(find.text('선택한 포켓몬 4마리'), findsOneWidget);
    expect(find.text('배정 후보 4마리 · 선택한 포켓몬만 사용'), findsOneWidget);
  });

  testWidgets('exclude pokemon search can show and clear empty result', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MyAppForTest(
        child: ExcludePokemonPage(
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
          selectedCategories: ['스피드형'],
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '없는포켓몬');
    await tester.pump();

    expect(find.text('검색 결과 0마리'), findsOneWidget);
    expect(find.text('"없는포켓몬" 검색 결과가 없습니다.'), findsOneWidget);
    expect(find.text('검색어 지우기'), findsOneWidget);

    await tester.tap(find.text('검색어 지우기'));
    await tester.pump();

    expect(find.text('"없는포켓몬" 검색 결과가 없습니다.'), findsNothing);
    expect(find.text('검색 결과 0마리'), findsNothing);
  });

  testWidgets('exclude pokemon search expands matching category', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MyAppForTest(
        child: ExcludePokemonPage(
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
          selectedCategories: ['어택형'],
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '피카츄');
    await tester.pump();

    expect(find.text('검색 결과 1마리'), findsOneWidget);
    expect(find.text('어택형 1마리'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, '피카츄'), findsOneWidget);
  });

  testWidgets('exclude pokemon selection shows assignable progress', (
    WidgetTester tester,
  ) async {
    final attackPokemonCount =
        pokemonList.where((pokemon) => pokemon['category'] == '어택형').length;

    await tester.pumpWidget(
      const MyAppForTest(
        child: ExcludePokemonPage(
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
          selectedCategories: ['어택형'],
        ),
      ),
    );

    expect(
      find.text('제외 0마리 · 배정 가능 $attackPokemonCount마리'),
      findsOneWidget,
    );
    expect(
      find.text('포켓몬을 검색하거나 포지션을 열어 제외할 후보를 선택하세요.'),
      findsOneWidget,
    );
    expect(
      find.text('적용 포지션 어택형 · 제외 0마리 · 배정 가능 $attackPokemonCount마리'),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics && widget.properties.label == '제외 포켓몬 배정 조건',
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.casino), findsOneWidget);
    expect(find.bySemanticsLabel('배정 가능 포켓몬 후보 진행률'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(
      tester
          .widget<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator),
          )
          .value,
      1,
    );

    await tester.enterText(find.byType(TextField), '피카츄');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, '피카츄'));
    await tester.pumpAndSettle();

    expect(
      find.text('제외 1마리 · 배정 가능 ${attackPokemonCount - 1}마리'),
      findsOneWidget,
    );
    expect(
      find.text(
        '적용 포지션 어택형 · 제외 1마리 · 배정 가능 ${attackPokemonCount - 1}마리',
      ),
      findsOneWidget,
    );
    expect(find.text('제외한 포켓몬 1마리'), findsOneWidget);
    expect(
      tester
          .widget<InputChip>(find.widgetWithText(InputChip, '피카츄'))
          .deleteButtonTooltipMessage,
      '피카츄 삭제',
    );
    expect(find.text('전체 해제'), findsOneWidget);
    expect(find.byIcon(Icons.clear_all), findsOneWidget);
    expect(
      tester
          .widget<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator),
          )
          .value,
      closeTo((attackPokemonCount - 1) / attackPokemonCount, 0.001),
    );

    await tester.tap(find.text('전체 해제'));
    await tester.pumpAndSettle();

    expect(
      find.text('제외 0마리 · 배정 가능 $attackPokemonCount마리'),
      findsOneWidget,
    );
    expect(
      find.text('적용 포지션 어택형 · 제외 0마리 · 배정 가능 $attackPokemonCount마리'),
      findsOneWidget,
    );
    expect(find.text('제외한 포켓몬 1마리'), findsNothing);
    expect(find.text('제외한 포켓몬을 모두 해제했습니다.'), findsOneWidget);
    expect(find.text('되돌리기'), findsOneWidget);

    await tester.tap(find.byType(SnackBarAction));
    await tester.pump();

    expect(
      find.text('제외 1마리 · 배정 가능 ${attackPokemonCount - 1}마리'),
      findsOneWidget,
    );
    expect(find.text('제외한 포켓몬 1마리'), findsOneWidget);
    expect(
      find.text(
        '적용 포지션 어택형 · 제외 1마리 · 배정 가능 ${attackPokemonCount - 1}마리',
      ),
      findsOneWidget,
    );
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
