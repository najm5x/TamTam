import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamtam/presentation/layout/match_layout.dart';
import 'package:tamtam/presentation/screens/visual_calibration_screen.dart';

void main() {
  group('CalibrationLayoutMetrics (2P-overflow regression)', () {
    // CustomPaint's RenderBox is clamped to its incoming constraints
    // regardless of what size is requested, so an oversized canvasWidth
    // does not throw -- it just draws content past the clamped box. Only a
    // direct check on the computed metrics catches that.
    test('canvasWidth never exceeds availableWidth, for every profile', () {
      for (final profile in [MatchLayoutProfile.twoPlayer, MatchLayoutProfile.fourPlayer]) {
        for (final availableWidth in [300.0, 360.0, 390.0, 430.0, 800.0]) {
          final metrics = CalibrationLayoutMetrics.compute(availableWidth, profile);
          expect(metrics.canvasWidth, lessThanOrEqualTo(availableWidth + 0.001),
              reason: '${profile.topology} at $availableWidth should not overflow');
          expect(metrics.canvasWidth, closeTo(availableWidth, 0.01),
              reason: '${profile.topology} at $availableWidth should use the full available width');
          expect(metrics.displayedBoardSize, greaterThan(0));
        }
      }
    });

    test('2P reserves no horizontal margin (no side frames to clear)', () {
      final metrics = CalibrationLayoutMetrics.compute(400, MatchLayoutProfile.twoPlayer);
      expect(metrics.marginX, 0);
      expect(metrics.displayedBoardSize, 400);
    });

    test('4P reserves horizontal margin matching MatchLayoutProfile.boardScaleRatio', () {
      final metrics = CalibrationLayoutMetrics.compute(400, MatchLayoutProfile.fourPlayer);
      expect(metrics.displayedBoardSize, closeTo(400 * MatchLayoutProfile.fourPlayer.boardScaleRatio, 0.01));
      expect(metrics.marginX, greaterThan(0));
    });
  });

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
