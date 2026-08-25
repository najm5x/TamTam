import 'package:flutter/material.dart';
import '../skins/piece_skin.dart';
import '../skins/skin_selection.dart';
import '../../domain/models/seat.dart';

/// A single board cell. Home/Gate/Finish visuals are baked into the board
/// skin's art (see BoardSkin.tamtam) so this only positions pieces -- it no
/// longer paints cell fills, gate arrows, or borders itself.
class BoardCellView extends StatelessWidget {
  final String coordinate;
  final List<Seat> pieces;

  const BoardCellView({
    super.key,
    required this.coordinate,
    this.pieces = const [],
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: pieces.isEmpty ? null : Center(child: _buildPieces()),
    );
  }

  Widget _buildPieces() {
    if (pieces.length == 1) {
      return _buildPiece(pieces.first);
    }
    // Multiple pieces — compact offset stacking
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth * 0.45;
        final offsets = <Offset>[
          Offset(-size * 0.2, -size * 0.2),
          Offset(size * 0.2, size * 0.2),
          if (pieces.length > 2) Offset(size * 0.2, -size * 0.2),
          if (pieces.length > 3) Offset(-size * 0.2, size * 0.2),
        ];
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: List.generate(pieces.length, (i) {
            final offset = i < offsets.length ? offsets[i] : Offset.zero;
            return Transform.translate(
              offset: offset,
              child: _buildPiece(pieces[i], small: true),
            );
          }),
        );
      },
    );
  }

  Widget _buildPiece(Seat seat, {bool small = false}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Target 80% of cell width for single piece, 45% for stacked
        final double size = small
            ? constraints.maxWidth * 0.45
            : constraints.maxWidth * 0.80;

        // Piece anchor/size stay driven by the cell's own LayoutBuilder
        // constraints above -- the skin only supplies the visual, never the
        // position or scale, so movement/animation code is unaffected.
        return ValueListenableBuilder<PieceSkin>(
          valueListenable: SkinSelection.piece,
          builder: (context, pieceSkin, _) {
            return SizedBox(
              width: size,
              height: size,
              child: pieceSkin.builder(context, seat),
            );
          },
        );
      },
    );
  }
}
