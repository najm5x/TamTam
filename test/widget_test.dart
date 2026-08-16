import 'package:flutter_test/flutter_test.dart';
import 'package:tamtam/main.dart';

void main() {
  testWidgets('App boots without crashing smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TamTamApp());
    expect(find.text('TAMTAM'), findsWidgets);
  });
}
