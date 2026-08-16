import 'package:flutter_test/flutter_test.dart';
import 'package:tamtam/presentation/layout/board_geometry.dart';
import 'package:tamtam/presentation/layout/match_layout.dart';
import 'package:tamtam/presentation/layout/visual_layout_contract.dart';

void main() {
  group('MatchLayoutProfile seat visibility', () {
    test('2P hides side player slots', () {
      const profile = MatchLayoutProfile.twoPlayer;
      expect(profile.visibleSeats.top, isTrue);
      expect(profile.visibleSeats.bottom, isTrue);
      expect(profile.visibleSeats.left, isFalse);
      expect(profile.visibleSeats.right, isFalse);
      expect(profile.visibleSeats.visibleCount, 2);
      expect(profile.boardScaleRatio, 1.0);
    });

    test('4P shows all four slots', () {
      final profile = MatchLayoutProfile.fourPlayer;
      expect(profile.visibleSeats.visibleCount, 4);
      expect(profile.boardScaleRatio, greaterThan(0));
      expect(profile.boardScaleRatio, lessThan(1.0));
    });

    test('forPlayerCount selects the right profile', () {
      expect(MatchLayoutProfile.forPlayerCount(2).topology, MatchTopology.twoPlayer);
      expect(MatchLayoutProfile.forPlayerCount(4).topology, MatchTopology.fourPlayer);
    });
  });

  group('Player-frame anchors do not overlap the playable grid rect (regression)', () {
    // The board canvas reserves a 5% margin on each side for the playable
    // grid (grid spans 0.05..0.95 of the 1080 canvas). The frame contract's
    // anchor offsets are tuned so a frame's inner edge lands exactly on that
    // boundary. If either contract's numbers drift independently, frames
    // would start covering live cells.
    test('frame edges sit exactly at the grid boundary, never inside it', () {
      const half = PlayerFrameContract.sizeRatio / 2;

      final rightInnerEdge = PlayerFrameContract.anchorRatios[FrameAnchor.right]!.dx - half;
      final leftInnerEdge = PlayerFrameContract.anchorRatios[FrameAnchor.left]!.dx + half;
      final topInnerEdge = PlayerFrameContract.anchorRatios[FrameAnchor.top]!.dy + half;
      final bottomInnerEdge = PlayerFrameContract.anchorRatios[FrameAnchor.bottom]!.dy - half;

      expect(rightInnerEdge, closeTo(BoardGeometry.gridEndRatio, 1e-9));
      expect(leftInnerEdge, closeTo(BoardGeometry.gridStartRatio, 1e-9));
      expect(topInnerEdge, closeTo(BoardGeometry.gridStartRatio, 1e-9));
      expect(bottomInnerEdge, closeTo(BoardGeometry.gridEndRatio, 1e-9));
    });
  });
}
