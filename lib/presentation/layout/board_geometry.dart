import 'dart:ui';

/// The canonical 1080x1080 design-space geometry every board skin renders into.
///
/// This is presentation-only: gameplay truth lives in the canonical route JSON
/// and the domain engine. Nothing here may be treated as movement/capture truth --
/// it only maps a canonical coordinate string (e.g. "E5") to a design-space pixel
/// so skins can be swapped without repositioning gameplay.
class BoardGeometry {
  BoardGeometry._();

  static const double canvasSize = 1080;
  static const double gridOrigin = 54;
  static const double gridSize = 972;
  static const double cellSize = 108;
  static const int gridCells = 9;

  static const List<String> columns = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I'];

  /// Fraction of the canvas (0..1) at which the playable grid begins/ends.
  /// Deliberately equal to the player-frame anchor offsets in
  /// [PlayerFrameContract] -- see match_layout_test.dart for the cross-check.
  static const double gridStartRatio = gridOrigin / canvasSize;
  static const double gridEndRatio = (gridOrigin + gridSize) / canvasSize;

  static int columnIndex(String column) => columns.indexOf(column);

  static String columnLetter(int index) => columns[index];

  /// Parses a canonical coordinate like "E5" into (columnIndex, rowIndex), both 0..8.
  /// Column A..I -> 0..8, row 1..9 -> 0..8 (row 0 is the top row).
  static (int, int) parseCoordinate(String coordinate) {
    final column = coordinate.substring(0, 1);
    final row = int.parse(coordinate.substring(1));
    return (columnIndex(column), row - 1);
  }

  static String formatCoordinate(int columnIndex, int rowIndex) {
    return '${columnLetter(columnIndex)}${rowIndex + 1}';
  }

  /// Design-space center of a cell, given 0-indexed column/row.
  static Offset cellCenter(int columnIndex, int rowIndex) {
    return Offset(
      gridOrigin + (columnIndex + 0.5) * cellSize,
      gridOrigin + (rowIndex + 0.5) * cellSize,
    );
  }

  static Offset cellCenterForCoordinate(String coordinate) {
    final (col, row) = parseCoordinate(coordinate);
    return cellCenter(col, row);
  }

  /// Scales a design-space length (measured on the 1080 canvas) to the
  /// equivalent length on a board actually displayed at [displayedBoardSize].
  static double scale(double designValue, double displayedBoardSize) {
    return designValue / canvasSize * displayedBoardSize;
  }

  static Offset scaleOffset(Offset designOffset, double displayedBoardSize) {
    return Offset(
      scale(designOffset.dx, displayedBoardSize),
      scale(designOffset.dy, displayedBoardSize),
    );
  }
}
