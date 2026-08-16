class BoardCell {
  final int col; // 1..9 (A..I)
  final int row; // 1..9

  const BoardCell(this.col, this.row);

  /// Parse a string like "E5" into a BoardCell
  factory BoardCell.parse(String s) {
    if (s.length != 2) throw FormatException('Invalid cell format: $s');
    final colChar = s[0].toUpperCase();
    final rowChar = s[1];
    final col = colChar.codeUnitAt(0) - 'A'.codeUnitAt(0) + 1;
    final row = int.parse(rowChar);
    return BoardCell(col, row);
  }

  @override
  String toString() {
    final colStr = String.fromCharCode('A'.codeUnitAt(0) + col - 1);
    return '$colStr$row';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoardCell &&
          runtimeType == other.runtimeType &&
          col == other.col &&
          row == other.row;

  @override
  int get hashCode => col.hashCode ^ row.hashCode;
}
