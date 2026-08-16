import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamtam/presentation/screens/visual_calibration_screen.dart';

void main() {
  testWidgets('renders 2P calibration without throwing', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: VisualCalibrationScreen()));
    await tester.pump();
    expect(find.text('VISUAL CALIBRATION (DEBUG)'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('switching to 4P and a phone-width preset renders without throwing', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: VisualCalibrationScreen()));
    await tester.pump();

    await tester.tap(find.text('4P'));
    await tester.pump();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Full'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('360dp').last);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
