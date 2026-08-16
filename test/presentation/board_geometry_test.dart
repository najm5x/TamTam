import 'package:flutter_test/flutter_test.dart';
import 'package:tamtam/presentation/layout/board_geometry.dart';

void main() {
  group('BoardGeometry cell centers', () {
    test('A1 maps to the top-left cell center', () {
      expect(BoardGeometry.cellCenterForCoordinate('A1'), const Offset(108, 108));
    });

    test('I9 maps to the bottom-right cell center', () {
      expect(BoardGeometry.cellCenterForCoordinate('I9'), const Offset(972, 972));
    });

    test('E5 maps to the exact canvas center', () {
      expect(BoardGeometry.cellCenterForCoordinate('E5'), const Offset(540, 540));
    });

    test('reference centers from the visual layout contract', () {
      const expected = {
        'A1': Offset(108, 108),
        'E1': Offset(540, 108),
        'H1': Offset(864, 108),
        'A5': Offset(108, 540),
        'E5': Offset(540, 540),
        'I5': Offset(972, 540),
        'B9': Offset(216, 972),
        'E9': Offset(540, 972),
        'I9': Offset(972, 972),
      };
      for (final entry in expected.entries) {
        expect(BoardGeometry.cellCenterForCoordinate(entry.key), entry.value,
            reason: '${entry.key} should center at ${entry.value}');
      }
    });

    test('cellCenter formula matches centerX = 54 + (col+0.5)*108', () {
      for (var col = 0; col < 9; col++) {
        for (var row = 0; row < 9; row++) {
          final expected = Offset(54 + (col + 0.5) * 108, 54 + (row + 0.5) * 108);
          expect(BoardGeometry.cellCenter(col, row), expected);
        }
      }
    });
  });

  group('Coordinate parsing round-trip', () {
    test('parseCoordinate and formatCoordinate are inverses', () {
      for (final coord in ['A1', 'E5', 'I9', 'H1', 'B9', 'D5']) {
        final (col, row) = BoardGeometry.parseCoordinate(coord);
        expect(BoardGeometry.formatCoordinate(col, row), coord);
      }
    });

    test('column A..I map to index 0..8, row 1..9 map to index 0..8', () {
      expect(BoardGeometry.parseCoordinate('A1'), (0, 0));
      expect(BoardGeometry.parseCoordinate('I9'), (8, 8));
      expect(BoardGeometry.parseCoordinate('E5'), (4, 4));
    });
  });

  group('Cross-check against BoardWidget._toCoordinate orientation (regression)', () {
    // BoardWidget._toCoordinate(x, y) uses: col = ['A'..'I'][x], row = y + 1.
    // Row 0 renders at the top, column 0 renders at the left. BoardGeometry
    // must agree, or a skin built on this contract would render mirrored/
    // rotated relative to the live match board.
    String widgetToCoordinate(int x, int y) {
      const cols = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I'];
      return '${cols[x]}${y + 1}';
    }

    test('formatCoordinate agrees with BoardWidget for every cell', () {
      for (var x = 0; x < 9; x++) {
        for (var y = 0; y < 9; y++) {
          expect(BoardGeometry.formatCoordinate(x, y), widgetToCoordinate(x, y));
        }
      }
    });
  });

  group('Scaling', () {
    test('scale() maps design-space lengths onto a displayed board size', () {
      expect(BoardGeometry.scale(1080, 1080), 1080);
      expect(BoardGeometry.scale(1080, 360), 360);
      expect(BoardGeometry.scale(540, 360), 180);
    });
  });
}
