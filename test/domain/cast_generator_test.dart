import 'package:flutter_test/flutter_test.dart';
import 'package:tamtam/domain/models/cast_result.dart';

void main() {
  group('CastResult and generator logic', () {
    test('All 16 combinations test', () {
      final w = Face.white;
      final b = Face.black;

      // 4W -> 16 (1 combination)
      expect(CastResult([w, w, w, w]).value, 16);

      // 3W, 1B -> 2 (4 combinations)
      expect(CastResult([b, w, w, w]).value, 2);
      expect(CastResult([w, b, w, w]).value, 2);
      expect(CastResult([w, w, b, w]).value, 2);
      expect(CastResult([w, w, w, b]).value, 2);

      // 2W, 2B -> 4 (6 combinations)
      expect(CastResult([b, b, w, w]).value, 4);
      expect(CastResult([b, w, b, w]).value, 4);
      expect(CastResult([b, w, w, b]).value, 4);
      expect(CastResult([w, b, b, w]).value, 4);
      expect(CastResult([w, b, w, b]).value, 4);
      expect(CastResult([w, w, b, b]).value, 4);

      // 1W, 3B -> 6 (4 combinations)
      expect(CastResult([w, b, b, b]).value, 6);
      expect(CastResult([b, w, b, b]).value, 6);
      expect(CastResult([b, b, w, b]).value, 6);
      expect(CastResult([b, b, b, w]).value, 6);

      // 4B -> 32 (1 combination)
      expect(CastResult([b, b, b, b]).value, 32);
    });

    test('Throws on invalid length', () {
      expect(() => CastResult([Face.white, Face.white, Face.white]), throwsArgumentError);
      expect(() => CastResult([Face.white, Face.white, Face.white, Face.white, Face.white]), throwsArgumentError);
    });
  });
}
