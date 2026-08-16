enum Face {
  white,
  black
}

class CastResult {
  final List<Face> faces; // exactly 4 faces

  CastResult(this.faces) {
    if (faces.length != 4) {
      throw ArgumentError('CastResult must have exactly 4 faces');
    }
  }

  int get whiteCount => faces.where((f) => f == Face.white).length;
  int get blackCount => faces.where((f) => f == Face.black).length;

  int get value {
    final w = whiteCount;
    if (w == 3) return 2;
    if (w == 2) return 4;
    if (w == 1) return 6;
    if (w == 4) return 16;
    if (w == 0) return 32;
    throw StateError('Invalid cast state');
  }
}
