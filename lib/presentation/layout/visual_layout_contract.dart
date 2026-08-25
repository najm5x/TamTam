import 'dart:ui';

/// Fixed ratio/slot contracts every cosmetic skin must snap into.
///
/// "Layout owns geometry. Skins only fill predefined slots." Nothing in this
/// file may depend on a specific skin's artwork, and the domain layer must
/// never import it.

enum FrameAnchor { top, right, bottom, left }

/// Player/profile-frame placement and artwork safe zones.
class PlayerFrameContract {
  PlayerFrameContract._();

  static const double sizeRatio = 0.16;

  /// Frame-center position as a fraction of displayed board size, relative
  /// to the board's top-left corner.
  static const Map<FrameAnchor, Offset> anchorRatios = {
    FrameAnchor.top: Offset(0.50, -0.03),
    FrameAnchor.right: Offset(1.03, 0.50),
    FrameAnchor.bottom: Offset(0.50, 1.03),
    FrameAnchor.left: Offset(-0.03, 0.50),
  };

  static double frameSize(double displayedBoardSize) => sizeRatio * displayedBoardSize;

  /// Frame center in display pixels, relative to the board's top-left.
  static Offset centerFor(FrameAnchor anchor, double displayedBoardSize) {
    final ratio = anchorRatios[anchor]!;
    return Offset(ratio.dx * displayedBoardSize, ratio.dy * displayedBoardSize);
  }

  // Frame artwork canvas.
  static const double artCanvasSize = 512;
  static const Offset portraitSafeCircleCenter = Offset(256, 210);
  static const double portraitSafeCircleDiameter = 300;
  static const Rect nameplateSafeRect = Rect.fromLTWH(80, 360, 352, 90);
}

/// Piece placement and artwork sizing.
class PieceContract {
  PieceContract._();

  static const double artCanvasSize = 512;
  static const double normalSizeRatio = 0.80;
  static const double stackedSizeRatio = 0.44;

  static double normalSize(double cellSize) => normalSizeRatio * cellSize;
  static double stackedSize(double cellSize) => stackedSizeRatio * cellSize;
}

/// Programmatic gate-arrow overlay. No skin may bake this into board art.
class GateOverlayContract {
  GateOverlayContract._();

  static const double sizeRatio = 0.20;
  static const double minOpacity = 0.32;
  static const double maxOpacity = 0.40;

  static double arrowSize(double cellSize) => sizeRatio * cellSize;
}

/// Home/Finish semantic overlay rules (programmatic, not baked into skins).
class HomeFinishContract {
  HomeFinishContract._();

  static const bool homeGetsFullColorFill = true;
  static const bool finishIsSharedNeutral = true;
  static const bool preFinishGetsFullColorFill = false;
}

/// Cast tray placement and its four fixed cube slots.
class CastTrayContract {
  CastTrayContract._();

  static const double artCanvasWidth = 1000;
  static const double artCanvasHeight = 240;
  static const double aspectRatio = artCanvasWidth / artCanvasHeight;
  static const double widthRatio = 0.75;
  static const int cubeSlotCount = 4;

  static double displayWidth(double displayedBoardSize) => widthRatio * displayedBoardSize;
  static double displayHeight(double displayedBoardSize) => displayWidth(displayedBoardSize) / aspectRatio;

  /// The four fixed slot centers within the tray, as fractions (0..1) of
  /// the tray's own width/height. Slots are evenly spaced and centered.
  static List<Offset> slotCenterRatios() {
    return List.generate(cubeSlotCount, (i) {
      final x = (i + 0.5) / cubeSlotCount;
      return Offset(x, 0.5);
    });
  }
}

/// TamTam cube/dice skin contract: always binary White/Black, never pips.
class DiceSkinContract {
  DiceSkinContract._();

  static const double artCanvasSize = 512;
  static const int faceCount = 2;
}
