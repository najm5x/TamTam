import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamtam/domain/routes/canonical_routes.dart';

void main() {
  group('Canonical Routes Invariants', () {
    test('Top player routes', () {
      expect(CanonicalRoutes.topHome, 'E1');
      expect(CanonicalRoutes.topGate, 'H1');
      expect(CanonicalRoutes.topFirstInwardCell, 'H2');
      expect(CanonicalRoutes.topPreFinish, 'E4');
      expect(CanonicalRoutes.topFinish, 'E5');

      expect(CanonicalRoutes.topFirstRound.length, 33);
      expect(CanonicalRoutes.topFirstRound.first, 'E1');
      expect(CanonicalRoutes.topFirstRound.last, 'E1');

      expect(CanonicalRoutes.topSecondRound.length, 79);
      expect(CanonicalRoutes.topSecondRound.first, 'E1');
      expect(CanonicalRoutes.topSecondRound.last, 'E5');

      expect(CanonicalRoutes.topClassicUnified.length, 111);
      expect(CanonicalRoutes.topClassicUnified.first, 'E1');
      expect(CanonicalRoutes.topClassicUnified[32], 'E1'); // End of first round
      expect(CanonicalRoutes.topClassicUnified[61], 'H1'); // Gate
      expect(CanonicalRoutes.topClassicUnified.last, 'E5');
    });

    test('Right player routes', () {
      expect(CanonicalRoutes.rightHome, 'I5');
      expect(CanonicalRoutes.rightGate, 'I8');
      expect(CanonicalRoutes.rightFirstInwardCell, 'H8');
      expect(CanonicalRoutes.rightPreFinish, 'F5');
      expect(CanonicalRoutes.rightFinish, 'E5');

      expect(CanonicalRoutes.rightFirstRound.length, 33);
      expect(CanonicalRoutes.rightFirstRound.first, 'I5');
      expect(CanonicalRoutes.rightFirstRound.last, 'I5');

      expect(CanonicalRoutes.rightSecondRound.length, 79);
      expect(CanonicalRoutes.rightSecondRound.first, 'I5');
      expect(CanonicalRoutes.rightSecondRound.last, 'E5');

      expect(CanonicalRoutes.rightClassicUnified.length, 111);
      expect(CanonicalRoutes.rightClassicUnified.first, 'I5');
      expect(CanonicalRoutes.rightClassicUnified[32], 'I5');
      expect(CanonicalRoutes.rightClassicUnified[61], 'I8');
      expect(CanonicalRoutes.rightClassicUnified.last, 'E5');
    });

    test('Bottom player routes', () {
      expect(CanonicalRoutes.bottomHome, 'E9');
      expect(CanonicalRoutes.bottomGate, 'B9');
      expect(CanonicalRoutes.bottomFirstInwardCell, 'B8');
      expect(CanonicalRoutes.bottomPreFinish, 'E6');
      expect(CanonicalRoutes.bottomFinish, 'E5');

      expect(CanonicalRoutes.bottomFirstRound.length, 33);
      expect(CanonicalRoutes.bottomFirstRound.first, 'E9');
      expect(CanonicalRoutes.bottomFirstRound.last, 'E9');

      expect(CanonicalRoutes.bottomSecondRound.length, 79);
      expect(CanonicalRoutes.bottomSecondRound.first, 'E9');
      expect(CanonicalRoutes.bottomSecondRound.last, 'E5');

      expect(CanonicalRoutes.bottomClassicUnified.length, 111);
      expect(CanonicalRoutes.bottomClassicUnified.first, 'E9');
      expect(CanonicalRoutes.bottomClassicUnified[32], 'E9');
      expect(CanonicalRoutes.bottomClassicUnified[61], 'B9');
      expect(CanonicalRoutes.bottomClassicUnified.last, 'E5');
    });

    test('Left player routes', () {
      expect(CanonicalRoutes.leftHome, 'A5');
      expect(CanonicalRoutes.leftGate, 'A2');
      expect(CanonicalRoutes.leftFirstInwardCell, 'B2');
      expect(CanonicalRoutes.leftPreFinish, 'D5');
      expect(CanonicalRoutes.leftFinish, 'E5');

      expect(CanonicalRoutes.leftFirstRound.length, 33);
      expect(CanonicalRoutes.leftFirstRound.first, 'A5');
      expect(CanonicalRoutes.leftFirstRound.last, 'A5');

      expect(CanonicalRoutes.leftSecondRound.length, 79);
      expect(CanonicalRoutes.leftSecondRound.first, 'A5');
      expect(CanonicalRoutes.leftSecondRound.last, 'E5');

      expect(CanonicalRoutes.leftClassicUnified.length, 111);
      expect(CanonicalRoutes.leftClassicUnified.first, 'A5');
      expect(CanonicalRoutes.leftClassicUnified[32], 'A5');
      expect(CanonicalRoutes.leftClassicUnified[61], 'A2');
      expect(CanonicalRoutes.leftClassicUnified.last, 'E5');
    });

    test('JSON Parity', () {
      final jsonFile = File('assets/routes/04_Canonical_Routes.json');
      final jsonStr = jsonFile.readAsStringSync();
      final Map<String, dynamic> data = jsonDecode(jsonStr);
      final players = data['players'] as Map<String, dynamic>;

      void checkList(List<String> generated, List<dynamic> expected) {
        expect(generated.length, expected.length);
        for (int i = 0; i < generated.length; i++) {
          expect(generated[i], expected[i]);
        }
      }

      checkList(CanonicalRoutes.topFirstRound, players['top']['first_round']);
      checkList(CanonicalRoutes.topSecondRound, players['top']['second_round']);
      checkList(CanonicalRoutes.topClassicUnified, players['top']['classic_unified']);

      checkList(CanonicalRoutes.rightFirstRound, players['right']['first_round']);
      checkList(CanonicalRoutes.rightSecondRound, players['right']['second_round']);
      checkList(CanonicalRoutes.rightClassicUnified, players['right']['classic_unified']);

      checkList(CanonicalRoutes.bottomFirstRound, players['bottom']['first_round']);
      checkList(CanonicalRoutes.bottomSecondRound, players['bottom']['second_round']);
      checkList(CanonicalRoutes.bottomClassicUnified, players['bottom']['classic_unified']);

      checkList(CanonicalRoutes.leftFirstRound, players['left']['first_round']);
      checkList(CanonicalRoutes.leftSecondRound, players['left']['second_round']);
      checkList(CanonicalRoutes.leftClassicUnified, players['left']['classic_unified']);
    });
  });
}
