import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/main.dart';

void main() {
  testWidgets('App arranca y muestra la Pokédex', (tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
    expect(find.text('Pokédex'), findsOneWidget); // AppBar title
  });
}
