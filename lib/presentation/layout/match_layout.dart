import 'visual_layout_contract.dart';

/// Pure layout-profile computation for 2P vs 4P match topology.
///
/// This file only computes ratios/visibility; it does not build widgets and
/// must not be reached for by widgets that only need a board (e.g. the
/// existing MatchScreen), which stays on its current layout until Phase 4's
/// calibration screen is approved.
class SeatVisibility {
  final bool top;
  final bool right;
  final bool bottom;
  final bool left;

  const SeatVisibility({
    required this.top,
    required this.right,
    required this.bottom,
    required this.left,
  });

  int get visibleCount => [top, right, bottom, left].where((v) => v).length;
}

enum MatchTopology { twoPlayer, fourPlayer }

class MatchLayoutProfile {
  final MatchTopology topology;
  final SeatVisibility visibleSeats;

  /// Fraction of the available square layout space the board itself should
  /// occupy, so that side player frames (when visible) stay on-screen.
  final double boardScaleRatio;

  const MatchLayoutProfile({
    required this.topology,
    required this.visibleSeats,
    required this.boardScaleRatio,
  });

  static const twoPlayer = MatchLayoutProfile(
    topology: MatchTopology.twoPlayer,
    visibleSeats: SeatVisibility(top: true, right: false, bottom: true, left: false),
    // No side frames reserved: the board can use the full available width.
    boardScaleRatio: 1.0,
  );

  static final fourPlayer = MatchLayoutProfile(
    topology: MatchTopology.fourPlayer,
    visibleSeats: const SeatVisibility(top: true, right: true, bottom: true, left: true),
    boardScaleRatio: _fourPlayerBoardScaleRatio,
  );

  /// Derived (not guessed) from PlayerFrameContract: side frames extend
  /// sizeRatio/2 beyond their anchor on both sides, so the available square
  /// must fit board + both frame overhangs.
  static double get _fourPlayerBoardScaleRatio {
    final half = PlayerFrameContract.sizeRatio / 2;
    final rightEdge = PlayerFrameContract.anchorRatios[FrameAnchor.right]!.dx + half;
    final leftEdge = PlayerFrameContract.anchorRatios[FrameAnchor.left]!.dx - half;
    final horizontalExtentRatio = rightEdge - leftEdge;
    return 1 / horizontalExtentRatio;
  }

  static MatchLayoutProfile forPlayerCount(int playerCount) {
    return playerCount > 2 ? fourPlayer : twoPlayer;
  }

  double boardSizeFor(double availableSquareSize) => availableSquareSize * boardScaleRatio;
}
