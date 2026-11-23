import 'dart:ui' show SemanticsFlag;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokemonbattle/data/pokemon_data.dart';
import 'package:pokemonbattle/main.dart';
import 'package:pokemonbattle/pokemon/result_page.dart';
import 'package:pokemonbattle/pokemon/pokemon_category_page.dart';
import 'package:pokemonbattle/pokemon/pokemon_assignment_page.dart';

void main() {
  final names = List.generate(10, (i) => '참가자${i + 1}');

  Future<void> openHome(WidgetTester tester, Size size) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();
  }

  Future<void> press(WidgetTester tester, String label) async {
    await tester.pumpAndSettle();
    final target = find.text(label).last;
    await tester.ensureVisible(target);
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  Future<void> fillNames(WidgetTester tester) async {
    for (var i = 0; i < names.length; i++) {
      final field = find.byKey(ValueKey('player-$i'));
      await tester.ensureVisible(field);
      await tester.enterText(field, names[i]);
    }
    await tester.pumpAndSettle();
  }

  testWidgets(
      'roster paste is a cancellable draft and reports source line numbers',
      (tester) async {
    await openHome(tester, const Size(375, 667));
    await press(tester, '10명을 두 팀으로 나누기');
    await tester.enterText(find.byKey(const ValueKey('player-0')), '기존 이름');
    for (final cancel in [true, false]) {
      await press(tester, '명단 붙여넣기');
      final draft = find.byType(TextField);
      final apply = find.widgetWithText(FilledButton, '명단 적용');
      await tester.enterText(draft, names.take(9).join('\n'));
      await tester.pump();
      expect(find.text('참가자 1명을 더 입력해 주세요.'), findsOneWidget);
      expect(tester.widget<FilledButton>(apply).enabled, isFalse);
      await tester.enterText(draft, [...names, '추가'].join('\n'));
      await tester.pump();
      expect(find.text('참가자를 1명 줄여 주세요.'), findsOneWidget);
      expect(tester.widget<FilledButton>(apply).enabled, isFalse);
      await tester.enterText(
          draft, ['  첫 이름 ', '', '첫 이름', ...names.skip(2)].join('\r\n'));
      await tester.pump();
      expect(find.text('1, 3번째 줄의 이름이 같습니다. 첫 이름'), findsOneWidget);
      expect(tester.widget<FilledButton>(apply).enabled, isFalse);
      await tester.enterText(draft, names.join('\n'));
      await tester.pump();
      expect(tester.widget<FilledButton>(apply).enabled, isTrue);
      if (cancel) {
        await press(tester, '취소');
      } else {
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
      }
      expect(
          tester
              .widgetList<EditableText>(find.byType(EditableText))
              .map((w) => w.controller.text),
          ['기존 이름', ...List.filled(9, '')]);
    }
  });

  for (final fixedTeams in [false, true]) {
    testWidgets(
        'paste and edit a roster through assignment (fixedTeams=$fixedTeams)',
        (tester) async {
      await openHome(tester, const Size(375, 667));
      await press(tester, fixedTeams ? '정해진 팀에 포켓몬 배정' : '10명을 두 팀으로 나누기');
      await tester.enterText(find.byKey(const ValueKey('player-0')), '기존 이름');
      await press(tester, '명단 붙여넣기');
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      final expected = [...names]..[0] = '두 글자';
      await tester.enterText(find.byType(TextField),
          [' ', ...expected.map((name) => '  $name  '), ''].join('\r\n'));
      await tester.pumpAndSettle();
      if (fixedTeams) {
        expect(find.text(expected.take(5).join(' · ')), findsOneWidget);
        expect(find.text(expected.skip(5).join(' · ')), findsOneWidget);
      }
      await press(tester, '명단 적용');
      tester.view.resetViewInsets();
      await tester.pumpAndSettle();
      expect(
          tester
              .widgetList<EditableText>(find.byType(EditableText))
              .map((w) => w.controller.text),
          expected);
      expected[6] = '교체된 참가자';
      final seventh = find.byKey(const ValueKey('player-6'));
      await tester.ensureVisible(seventh);
      await tester.enterText(seventh, expected[6]);
      if (fixedTeams) {
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
        await press(tester, '정해진 팀에 포켓몬 배정');
        expect(
            tester
                .widgetList<EditableText>(find.byType(EditableText))
                .map((w) => w.controller.text),
            expected);
        await press(tester, '배정 방식 선택');
      } else {
        await press(tester, '팀 나누기');
        await press(tester, '이 팀으로 포켓몬 배정');
      }
      await press(tester, '포켓몬 배정하기');
      await press(tester, '전체 결과 보기');
      final result = tester.widget<ResultsPage>(find.byType(ResultsPage));
      expect([...result.team1, ...result.team2],
          fixedTeams ? orderedEquals(expected) : unorderedEquals(expected));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('mobile draw keeps the two teams through reveal and summary',
      (tester) async {
    await openHome(tester, const Size(360, 640));
    await press(tester, '10명을 두 팀으로 나누기');
    await fillNames(tester);
    await press(tester, '팀 나누기');
    final draw = tester.widget<ResultsPage>(find.byType(ResultsPage));
    await tester.ensureVisible(find.text(draw.team2.last));
    expect(find.text(draw.team2.last).hitTestable(), findsOneWidget);
    await press(tester, '이 팀으로 포켓몬 배정');
    await press(tester, '포켓몬 배정하기');
    expect(find.text(draw.team1.first), findsOneWidget);
    final firstReveal = pokemonList.singleWhere(
        (p) => find.text(p['name']!).evaluate().isNotEmpty)['name'];
    await press(tester, '전체 결과 보기');
    final summary = tester.widget<ResultsPage>(find.byType(ResultsPage));
    expect(summary.team1, draw.team1);
    expect(summary.team2, draw.team2);
    expect(summary.playerPokemonMap[draw.team1.first]!['name'], firstReveal);
    for (final team in [draw.team1, draw.team2]) {
      expect(
          team
              .map((name) => summary.playerPokemonMap[name]!['category'])
              .toSet(),
          hasLength(5));
    }
    await tester.ensureVisible(find.text(draw.team2.last));
    expect(find.text(draw.team2.last).hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'mobile keyboard advances across both teams and preserves the last name when dismissed',
      (tester) async {
    await openHome(tester, const Size(375, 667));
    await press(tester, '정해진 팀에 포켓몬 배정');
    await tester.tap(find.byKey(const ValueKey('player-0')));
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpAndSettle();

    for (var i = 0; i < names.length; i++) {
      final input = tester.widget<EditableText>(find.descendant(
          of: find.byKey(ValueKey('player-$i')),
          matching: find.byType(EditableText)));
      expect(input.focusNode.hasFocus, isTrue, reason: 'Field ${i + 1}');
      tester.testTextInput.enterText(names[i]);
      await tester.pump();
      await tester.testTextInput.receiveAction(
          i == names.length - 1 ? TextInputAction.done : TextInputAction.next);
      await tester.pumpAndSettle();
    }

    tester.view.resetViewInsets();
    await tester.pumpAndSettle();
    await press(tester, '배정 방식 선택');
    await press(tester, '포켓몬 배정하기');
    await press(tester, '전체 결과 보기');
    final result = tester.widget<ResultsPage>(find.byType(ResultsPage));
    expect(result.team1, names.take(5));
    expect(result.team2, names.skip(5));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'fixed teams restore visible names and preferred picks survive searches',
      (tester) async {
    await openHome(tester, const Size(375, 667));
    await press(tester, '정해진 팀에 포켓몬 배정');
    await fillNames(tester);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await press(tester, '정해진 팀에 포켓몬 배정');
    expect(
        tester
            .widgetList<EditableText>(find.byType(EditableText))
            .map((w) => w.controller.text),
        names);
    await tester.enterText(
        find.byKey(const ValueKey('player-1')), ' ${names.first} ');
    await tester.pump();
    expect(find.textContaining('같은 이름이 있습니다'), findsNWidgets(2));
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull);
    await tester.enterText(find.byKey(const ValueKey('player-1')), names[1]);
    await press(tester, '배정 방식 선택');
    await press(tester, '선호 목록에서 랜덤');
    await press(tester, '선호 포켓몬 선택');
    final search = find.byType(TextField);
    final pool = ['앱솔', '에이스번', '카디나르마', '번치코', '레시라무'];
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull);
    for (final name in pool) {
      await tester.enterText(search, name);
      await tester.pump();
      await press(tester, name);
      expect(
          tester
              .getSemantics(find.widgetWithText(FilterChip, name))
              .hasFlag(SemanticsFlag.isSelected),
          isTrue);
      expect(tester.widget<FilledButton>(find.byType(FilledButton)).enabled,
          name == pool.last);
    }
    await tester.enterText(search, '없는이름');
    await tester.pump();
    expect(find.textContaining('검색 결과가 없습니다'), findsOneWidget);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    tester.view.resetViewInsets();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('검색어 지우기'));
    await tester.pump();
    expect(find.byType(ExpansionTile), findsWidgets);
    await press(tester, '선택 목록 (5)');
    await tester.tap(find.byTooltip('앱솔 선택 해제'));
    await tester.pump();
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).enabled,
        isFalse);
    await tester.enterText(search, pool.first);
    await tester.pump();
    await press(tester, pool.first);
    await press(tester, '선택 5마리 · 배정하기');
    await press(tester, '전체 결과 보기');
    final summary = tester.widget<ResultsPage>(find.byType(ResultsPage));
    expect([...summary.team1, ...summary.team2], names);
    for (final team in [summary.team1, summary.team2]) {
      expect(team.map((name) => summary.playerPokemonMap[name]!['name']),
          unorderedEquals(pool));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'desktop keyboard can complete entry and reveal a selected-role roster',
      (tester) async {
    await openHome(tester, const Size(1200, 900));
    Future<void> key(LogicalKeyboardKey key) async {
      await tester.sendKeyEvent(key);
      await tester.pumpAndSettle();
    }

    Future<void> tabTo(Finder target) async {
      for (var i = 0; i < 40; i++) {
        final focused = FocusManager.instance.primaryFocus?.context;
        if (focused != null) {
          final current =
              find.byElementPredicate((element) => element == focused);
          if (find
                  .ancestor(of: current, matching: target)
                  .evaluate()
                  .isNotEmpty ||
              target.evaluate().contains(focused)) {
            return;
          }
        }
        await key(LogicalKeyboardKey.tab);
      }
      fail('Could not focus $target');
    }

    await key(LogicalKeyboardKey.tab);
    await key(LogicalKeyboardKey.enter);
    expect(find.text('참가자 입력'), findsOneWidget);
    for (var i = 0; i < names.length; i++) {
      await tabTo(find.byKey(ValueKey('player-$i')));
      tester.testTextInput.enterText(names[i]);
      await tester.pumpAndSettle();
    }
    await tabTo(find.byType(FilledButton));
    await key(LogicalKeyboardKey.enter);
    await tabTo(find.byType(FilledButton));
    await key(LogicalKeyboardKey.enter);
    await tabTo(find.ancestor(
        of: find.text('선택한 역할군에서 랜덤'),
        matching: find.byWidgetPredicate((widget) => widget is RadioListTile)));
    await key(LogicalKeyboardKey.space);
    await tabTo(find.widgetWithText(FilterChip, '어택형'));
    await key(LogicalKeyboardKey.space);
    await tabTo(find.byType(FilledButton));
    await key(LogicalKeyboardKey.enter);
    await tabTo(find.widgetWithText(FilledButton, '전체 결과 보기'));
    await key(LogicalKeyboardKey.enter);
    final summary = tester.widget<ResultsPage>(find.byType(ResultsPage));
    expect(summary.playerPokemonMap.values.every((p) => p['category'] == '어택형'),
        isTrue);
    expect(tester.getTopLeft(find.text('1팀')).dy,
        tester.getTopLeft(find.text('2팀')).dy);

    final readingOrder = tester.semantics
        .simulatedAccessibilityTraversal()
        .expand((node) => node.label.split('\n'))
        .where((text) => text == '1팀' || text == '2팀' || names.contains(text));
    expect(readingOrder, ['1팀', ...summary.team1, '2팀', ...summary.team2]);
  });

  testWidgets(
      'large Korean text fits mobile flow and exposes names to accessibility',
      (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await openHome(tester, const Size(360, 640));
    await press(tester, '정해진 팀에 포켓몬 배정');
    expect(find.bySemanticsLabel('1팀 참가자 1'), findsOneWidget);
    await fillNames(tester);
    await press(tester, '배정 방식 선택');
    await press(tester, '포켓몬 배정하기');
    await press(tester, '전체 결과 보기');
    await tester.ensureVisible(find.text(names.last));
    expect(find.text(names.last).hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('clearing the role filter assigns from all roles',
      (tester) async {
    await tester
        .pumpWidget(MaterialApp(home: PokemonCategoryPage(players: names)));
    await press(tester, '선택한 역할군에서 랜덤');
    expect(find.text('선택 없음 · 전체 역할군 사용'), findsOneWidget);
    await press(tester, '전체 선택');
    expect(
        tester
            .widgetList<FilterChip>(find.byType(FilterChip))
            .every((chip) => chip.selected),
        isTrue);
    await press(tester, '전체 해제');
    expect(
        tester
            .widgetList<FilterChip>(find.byType(FilterChip))
            .every((chip) => !chip.selected),
        isTrue);
    await press(tester, '포켓몬 배정하기');
    final page = tester
        .widget<PokemonAssignmentPage>(find.byType(PokemonAssignmentPage));
    expect(page.selectedCategories, unorderedEquals(pokemonRoles));
    expect(page.assignOneFromEach, isFalse);
    await press(tester, '전체 결과 보기');
    expect(
        tester.widget<ResultsPage>(find.byType(ResultsPage)).playerPokemonMap,
        hasLength(10));
  });

  testWidgets(
      'exclusion keeps the chosen role and uses only the five remaining candidates',
      (tester) async {
    await openHome(tester, const Size(360, 640));
    await press(tester, '정해진 팀에 포켓몬 배정');
    await fillNames(tester);
    await press(tester, '배정 방식 선택');
    await press(tester, '포켓몬 제외 후 랜덤');
    await press(tester, '서포트형');
    await press(tester, '제외할 포켓몬 선택');
    final candidates = pokemonList
        .where((p) => p['category'] == '서포트형')
        .map((p) => p['name']!)
        .toList();
    final search = find.byType(TextField);
    final action = find.byType(FilledButton);
    Future<void> toggle(String name) async {
      await tester.ensureVisible(search);
      await tester.enterText(search, name);
      await press(tester, name);
    }

    expect(find.text('제외 없이 랜덤 배정'), findsOneWidget);
    await toggle(candidates.first);
    await press(tester, '전체 해제');
    expect(find.text('제외 0마리 · 배정 가능 ${candidates.length}마리'), findsOneWidget);
    final excludedCount = candidates.length - 4;
    for (final name in candidates.take(excludedCount)) {
      await toggle(name);
    }
    expect(tester.widget<FilledButton>(action).enabled, isFalse);
    final restored = candidates[excludedCount - 1];
    await press(tester, '제외 목록 ($excludedCount)');
    final restore = find.byTooltip('$restored 선택 해제');
    await tester.ensureVisible(restore);
    await tester.tap(restore);
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(action).enabled, isTrue);
    await press(tester, '제외 목록으로 랜덤 배정');
    await press(tester, '전체 결과 보기');
    final summary = tester.widget<ResultsPage>(find.byType(ResultsPage));
    for (final team in [summary.team1, summary.team2]) {
      expect(team.map((name) => summary.playerPokemonMap[name]!['name']),
          unorderedEquals(candidates.skip(excludedCount - 1)));
    }
  });

  test('every registered portrait is in the asset bundle', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final assets = (await AssetManifest.loadFromAssetBundle(rootBundle))
        .listAssets()
        .toSet();
    for (final pokemon in pokemonList) {
      expect(assets, contains(pokemon['image']), reason: pokemon['name']);
    }
  });
}
