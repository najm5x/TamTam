import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'board_cell_view.dart';
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
          color: AppTheme.boardBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: _buildGrid(),
      ),
    );
  }

  Widget _buildGrid() {
    return Column(
      children: List.generate(9, (y) {
        return Expanded(
          child: Row(
            children: List.generate(9, (x) {
              final coord = _toCoordinate(x, y);
              final pieces = _getPiecesAt(coord);
              final homeColor = _getHomeColor(coord);
              final gateInfo = _getGateInfo(coord);
              final preFinishInfo = _getPreFinishInfo(coord);

              Color? cellColor;
              if (coord == 'E5') {
                cellColor = AppTheme.centerCellColor;
              } else if (homeColor != null) {
                cellColor = homeColor;
              }

              return Expanded(
                child: BoardCellView(
                  coordinate: coord,
                  cellColor: cellColor,
                  pieces: pieces,
                  gateForSeat: gateInfo?.$1,
                  gateDirection: gateInfo?.$2,
                  isPreFinish: preFinishInfo != null,
                  preFinishColor: preFinishInfo,
                ),
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

  /// Only Home cells get full player-color fill
  Color? _getHomeColor(String coord) {
    if (coord == 'E1') return AppTheme.topPlayerColor;
    if (coord == 'I5') return AppTheme.rightPlayerColor;
    if (coord == 'E9') return AppTheme.bottomPlayerColor;
    if (coord == 'A5') return AppTheme.leftPlayerColor;
    return null;
  }

  /// Gate cells: returns (seat, direction) for the arrow
  (Seat, String)? _getGateInfo(String coord) {
    // Top gate H1: arrow points down (inward toward H2)
    if (coord == 'H1') return (Seat.top, 'down');
    // Right gate I8: arrow points left (inward toward H8)
    if (coord == 'I8') return (Seat.right, 'left');
    // Bottom gate B9: arrow points up (inward toward B8)
    if (coord == 'B9') return (Seat.bottom, 'up');
    // Left gate A2: arrow points right (inward toward B2)
    if (coord == 'A2') return (Seat.left, 'right');
    return null;
  }

  /// Pre-finish cells: returns the player's color for subtle accent
  Color? _getPreFinishInfo(String coord) {
    if (coord == 'E4') return AppTheme.topPlayerColor;
    if (coord == 'F5') return AppTheme.rightPlayerColor;
    if (coord == 'E6') return AppTheme.bottomPlayerColor;
    if (coord == 'D5') return AppTheme.leftPlayerColor;
    return null;
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
