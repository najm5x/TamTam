import 'package:flutter/material.dart';
import 'board_cell_view.dart';
import '../skins/board_skin.dart';
import '../skins/skin_selection.dart';
import '../layout/board_geometry.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/seat.dart';
import '../../domain/routes/canonical_routes.dart';

class BoardWidget extends StatelessWidget {
  final GameState gameState;
  final Seat? animatingSeat;
  final String? animatingCoord;

  const BoardWidget({
    super.key,
    required this.gameState,
    this.animatingSeat,
    this.animatingCoord,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        // Cell centers/geometry stay fully programmatic (Column/Row of
        // Expanded cells below, one per canonical coordinate) -- only the
        // Home/Gate/Finish *visuals* now come from the board skin's art,
        // never gameplay truth or pixel-based hit-testing.
        child: ValueListenableBuilder<BoardSkin>(
          valueListenable: SkinSelection.board,
          builder: (context, boardSkin, _) {
            return Stack(
              fit: StackFit.expand,
              children: [
                boardSkin.backgroundBuilder(context),
                // The board art's playable grid is inset from the full
                // canvas (BoardGeometry.gridStartRatio..gridEndRatio, i.e.
                // 5% per side on the 1080 design canvas) -- the piece grid
                // must be inset by exactly that fraction too, or pieces sit
                // off the art's actual cell centers.
                FractionallySizedBox(
                  alignment: Alignment.center,
                  widthFactor: BoardGeometry.gridSize / BoardGeometry.canvasSize,
                  heightFactor: BoardGeometry.gridSize / BoardGeometry.canvasSize,
                  child: _buildGrid(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // board_tamtam_01.png already bakes in neutral cells, Home fills, gate
  // arrows, and the Finish ornament for AppTheme.seatColor's palette (see
  // BoardSkin.tamtam) -- the grid below only positions pieces on top of it,
  // it no longer paints any semantic overlay itself.
  Widget _buildGrid() {
    return Column(
      children: List.generate(9, (y) {
        return Expanded(
          child: Row(
            children: List.generate(9, (x) {
              final coord = _toCoordinate(x, y);
              final pieces = _getPiecesAt(coord);

              return Expanded(
                child: BoardCellView(coordinate: coord, pieces: pieces),
              );
            }),
          ),
        );
      }),
    );
  }

  String _toCoordinate(int x, int y) {
    final cols = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I'];
    final col = cols[x];
    final row = y + 1;
    return '$col$row';
  }

  List<Seat> _getPiecesAt(String coord) {
    final List<Seat> pieces = [];

    if (animatingSeat != null && animatingCoord == coord) {
      pieces.add(animatingSeat!);
    }

    for (final p in gameState.players) {
      if (animatingSeat != null && p.seat == animatingSeat) continue;

      if (p.progress < 0 || p.progress > gameState.ruleProfile.finishProgress) {
        continue;
      }

      final route = _getRouteForSeat(p.seat);
      if (route[p.progress] == coord) {
        pieces.add(p.seat);
      }
    }
    return pieces;
  }

  List<String> _getRouteForSeat(Seat seat) {
    switch (seat) {
      case Seat.top:
        return CanonicalRoutes.topClassicUnified;
      case Seat.right:
        return CanonicalRoutes.rightClassicUnified;
      case Seat.bottom:
        return CanonicalRoutes.bottomClassicUnified;
      case Seat.left:
        return CanonicalRoutes.leftClassicUnified;
    }
  }
}
