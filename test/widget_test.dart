import 'package:flutter_test/flutter_test.dart';
import 'package:appli_meteo/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MonAppliMeteo());

    // Verify that our counter starts at 0.
    expect(find.text('Choisissez une ville'), findsOneWidget);
    expect(find.text('Voir la météo'), findsOneWidget);

    // Tap the '+' icon and trigger a frame.
    // await tester.tap(find.byIcon(Icons.add));
    // await tester.pump();

    // Verify that our counter has incremented.
    // expect(find.text('0'), findsNothing);
    // expect(find.text('1'), findsOneWidget);
  });
}
