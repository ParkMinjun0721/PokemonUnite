import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pokemonbattle/main.dart';

void main() {
  testWidgets('shows home actions', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    expect(find.text('포켓몬 유나이트 내전 프로그램'), findsOneWidget);
    expect(find.text('팀 랜덤 배정'), findsOneWidget);
    expect(find.text('포켓몬 랜덤 선택'), findsOneWidget);
  });
}
