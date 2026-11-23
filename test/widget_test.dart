import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokemonbattle/data/pokemon_data.dart';
import 'package:pokemonbattle/main.dart';
import 'package:pokemonbattle/pokemon/result_page.dart';

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
      'fixed teams restore visible names and preferred picks survive searches',
      (tester) async {
    await openHome(tester, const Size(390, 844));
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
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull);
    for (final name in pool) {
      await tester.enterText(search, name);
      await tester.pump();
      await press(tester, name);
      expect(tester.widget<FilledButton>(find.byType(FilledButton)).enabled,
          name == pool.last);
    }
    await tester.enterText(search, '없는이름');
    await tester.pump();
    expect(find.textContaining('검색 결과가 없습니다'), findsOneWidget);
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
