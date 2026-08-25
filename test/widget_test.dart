import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamtam/main.dart';
import 'package:tamtam/presentation/screens/home_screen.dart';

void main() {
  testWidgets('App boots without crashing smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TamTamApp());
    // Home now renders the TamTam wordmark as the supplied logo artwork
    // rather than a Flutter Text widget, so the smoke test checks the
    // screen itself booted instead of a literal string.
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(Image), findsWidgets);
  });
}
