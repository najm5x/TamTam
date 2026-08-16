import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../layout/board_geometry.dart';
import '../layout/match_layout.dart';
import '../layout/visual_layout_contract.dart';
import '../theme/app_theme.dart';
import '../../domain/models/seat.dart';

/// DEBUG-ONLY. Renders the Visual Layout Contract (Phase 2) directly, with
/// deliberately ugly/high-contrast markers, so the user can verify
/// positions/scales on a real phone before any rich skin artwork is made.
///
/// Must never be reachable from a release build. This screen and its entry
/// point both check kReleaseMode; nothing else in the app links to it.
class VisualCalibrationScreen extends StatefulWidget {
  const VisualCalibrationScreen({super.key});

  @override
  State<VisualCalibrationScreen> createState() => _VisualCalibrationScreenState();
}

class _PhoneWidthPreset {
  final String label;
  final double? width; // null = use all available width
  const _PhoneWidthPreset(this.label, this.width);
}

const _phoneWidthPresets = [
  _PhoneWidthPreset('Full', null),
  _PhoneWidthPreset('360dp', 360),
  _PhoneWidthPreset('390dp', 390),
  _PhoneWidthPreset('430dp', 430),
];

class _VisualCalibrationScreenState extends State<VisualCalibrationScreen> {
  MatchTopology _topology = MatchTopology.twoPlayer;
  int _presetIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (kReleaseMode) {
      // Defense in depth: even if something ever routes here in release,
      // render nothing useful instead of the calibration overlay.
      return const Scaffold(body: SizedBox.shrink());
    }

    final profile = _topology == MatchTopology.twoPlayer
        ? MatchLayoutProfile.twoPlayer
        : MatchLayoutProfile.fourPlayer;

    return Scaffold(
      backgroundColor: const Color(0xFF202020),
      appBar: AppBar(
        title: const Text('VISUAL CALIBRATION (DEBUG)'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildControls(),
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _PhoneFrame(
                    width: _phoneWidthPresets[_presetIndex].width,
                    child: _CalibrationBoard(profile: profile),
                  ),
                ),
              ),
            ),
          ),
          _buildRatiosPanel(profile),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text('Topology:', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ToggleButtons(
            isSelected: [
              _topology == MatchTopology.twoPlayer,
              _topology == MatchTopology.fourPlayer,
            ],
            onPressed: (i) => setState(() {
              _topology = i == 0 ? MatchTopology.twoPlayer : MatchTopology.fourPlayer;
            }),
            color: Colors.white70,
            selectedColor: Colors.black,
            fillColor: Colors.amber,
            constraints: const BoxConstraints(minHeight: 32, minWidth: 48),
            children: const [Text('2P'), Text('4P')],
          ),
          const SizedBox(width: 16),
          const Text('Phone width:', style: TextStyle(color: Colors.white70, fontSize: 12)),
          DropdownButton<int>(
            value: _presetIndex,
            dropdownColor: Colors.black,
            style: const TextStyle(color: Colors.white),
            items: [
              for (var i = 0; i < _phoneWidthPresets.length; i++)
                DropdownMenuItem(value: i, child: Text(_phoneWidthPresets[i].label)),
            ],
            onChanged: (i) => setState(() => _presetIndex = i ?? 0),
          ),
        ],
      ),
    );
  }

  Widget _buildRatiosPanel(MatchLayoutProfile profile) {
    final lines = <String>[
      'Board canvas ${BoardGeometry.canvasSize.toInt()}x${BoardGeometry.canvasSize.toInt()}'
          '  |  grid ${BoardGeometry.gridSize.toInt()}x${BoardGeometry.gridSize.toInt()}'
          ' @ (${BoardGeometry.gridOrigin.toInt()},${BoardGeometry.gridOrigin.toInt()})'
          '  |  cell ${BoardGeometry.cellSize.toInt()}'
          '  |  grid ratio ${BoardGeometry.gridStartRatio.toStringAsFixed(3)}'
          '..${BoardGeometry.gridEndRatio.toStringAsFixed(3)}',
      'Frame size ratio ${PlayerFrameContract.sizeRatio}'
          '  |  anchors T${PlayerFrameContract.anchorRatios[FrameAnchor.top]}'
          ' R${PlayerFrameContract.anchorRatios[FrameAnchor.right]}'
          ' B${PlayerFrameContract.anchorRatios[FrameAnchor.bottom]}'
          ' L${PlayerFrameContract.anchorRatios[FrameAnchor.left]}',
      'Piece normal ${PieceContract.normalSizeRatio} x cell'
          '  |  stacked ${PieceContract.stackedSizeRatio} x cell',
      'Gate arrow ${GateOverlayContract.sizeRatio} x cell'
          '  |  opacity ${GateOverlayContract.minOpacity}-${GateOverlayContract.maxOpacity}',
      'Cast tray width ${CastTrayContract.widthRatio} x board'
          '  |  aspect ${CastTrayContract.artCanvasWidth.toInt()}:${CastTrayContract.artCanvasHeight.toInt()}'
          '  |  slots ${CastTrayContract.cubeSlotCount}',
      'Topology ${profile.topology.name}'
          '  |  board scale ratio ${profile.boardScaleRatio.toStringAsFixed(4)}'
          '  |  visible seats ${profile.visibleSeats.visibleCount}',
    ];

    return Container(
      width: double.infinity,
      color: Colors.black,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('MEASURED NORMALIZED RATIOS',
              style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          for (final line in lines)
            Text(line, style: const TextStyle(color: Colors.white70, fontSize: 10, fontFamily: 'monospace')),
        ],
      ),
    );
  }
}

/// Simulates a phone viewport width so portrait sizing can be previewed
/// without an actual device of that width.
class _PhoneFrame extends StatelessWidget {
  final double? width;
  final Widget child;

  const _PhoneFrame({required this.width, required this.child});

  @override
  Widget build(BuildContext context) {
    final content = Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.amber, width: 2)),
      padding: const EdgeInsets.all(8),
      child: child,
    );
    if (width == null) return content;
    return SizedBox(width: width, child: content);
  }
}

class _CalibrationBoard extends StatelessWidget {
  final MatchLayoutProfile profile;

  const _CalibrationBoard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final availableWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : 360.0;
      final displayedBoardSize = profile.boardSizeFor(availableWidth);

      final frameHalfRatio = PlayerFrameContract.sizeRatio / 2;
      final marginRatio =
          PlayerFrameContract.anchorRatios[FrameAnchor.right]!.dx + frameHalfRatio - 1.0;
      final margin = marginRatio * displayedBoardSize;

      const trayGap = 24.0;
      final trayHeight = CastTrayContract.displayHeight(displayedBoardSize);
      final trayPadding = 12.0;

      final canvasWidth = displayedBoardSize + 2 * margin;
      final canvasHeight = displayedBoardSize + 2 * margin + trayGap + trayHeight + trayPadding;

      return CustomPaint(
        size: Size(canvasWidth, canvasHeight),
        painter: _CalibrationPainter(
          displayedBoardSize: displayedBoardSize,
          margin: margin,
          profile: profile,
        ),
      );
    });
  }
}

class _CalibrationPainter extends CustomPainter {
  final double displayedBoardSize;
  final double margin;
  final MatchLayoutProfile profile;

  _CalibrationPainter({
    required this.displayedBoardSize,
    required this.margin,
    required this.profile,
  });

  double _sx(double designX) => margin + BoardGeometry.scale(designX, displayedBoardSize);
  double _sy(double designY) => margin + BoardGeometry.scale(designY, displayedBoardSize);
  Offset _designPoint(Offset design) => Offset(_sx(design.dx), _sy(design.dy));

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF303030));

    final cellSizePx = BoardGeometry.scale(BoardGeometry.cellSize, displayedBoardSize);

    _paintBoardCanvas(canvas);
    _paintGridRect(canvas, cellSizePx);
    _paintCellCenters(canvas);
    _paintHomes(canvas, cellSizePx);
    _paintGates(canvas, cellSizePx);
    _paintFinish(canvas, cellSizePx);
    _paintPlayerFrames(canvas);
    _paintPieceBoundingCircle(canvas, cellSizePx);
    _paintCastTray(canvas, size);
  }

  void _paintBoardCanvas(Canvas canvas) {
    final rect = Rect.fromLTWH(margin, margin, displayedBoardSize, displayedBoardSize);
    canvas.drawRect(rect, Paint()..color = const Color(0xFFFFF8E7));
    canvas.drawRect(
      rect,
      Paint()
        ..color = const Color(0xFFFF00FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    _label(canvas, '1080 CANVAS', Offset(rect.left + 4, rect.top - 12), color: const Color(0xFFFF00FF), align: TextAlign.left);
  }

  void _paintGridRect(Canvas canvas, double cellSizePx) {
    final rect = Rect.fromLTWH(
      _sx(BoardGeometry.gridOrigin),
      _sy(BoardGeometry.gridOrigin),
      BoardGeometry.scale(BoardGeometry.gridSize, displayedBoardSize),
      BoardGeometry.scale(BoardGeometry.gridSize, displayedBoardSize),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..color = const Color(0xFF00FFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final gridLinePaint = Paint()
      ..color = const Color(0x66FF00FF)
      ..strokeWidth = 1;
    for (var i = 0; i <= BoardGeometry.gridCells; i++) {
      final x = rect.left + i * cellSizePx;
      canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), gridLinePaint);
      final y = rect.top + i * cellSizePx;
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), gridLinePaint);
    }
  }

  void _paintCellCenters(Canvas canvas) {
    final dotPaint = Paint()..color = const Color(0xFFFF3B3B);
    for (var col = 0; col < 9; col++) {
      for (var row = 0; row < 9; row++) {
        final center = _designPoint(BoardGeometry.cellCenter(col, row));
        canvas.drawCircle(center, 2, dotPaint);
      }
    }
  }

  void _paintHomes(Canvas canvas, double cellSizePx) {
    const homes = {'E1': Seat.top, 'I5': Seat.right, 'E9': Seat.bottom, 'A5': Seat.left};
    for (final entry in homes.entries) {
      final center = _designPoint(BoardGeometry.cellCenterForCoordinate(entry.key));
      final rect = Rect.fromCenter(center: center, width: cellSizePx, height: cellSizePx);
      canvas.drawRect(rect, Paint()..color = AppTheme.seatColor(entry.value).withValues(alpha: 0.55));
      canvas.drawRect(rect, Paint()..color = const Color(0xFF39FF14)..style = PaintingStyle.stroke..strokeWidth = 2);
      _label(canvas, 'HOME\n${entry.key}', center, color: Colors.black);
    }
  }

  void _paintGates(Canvas canvas, double cellSizePx) {
    const gates = {
      'H1': (Seat.top, Offset(0, 1)),
      'I8': (Seat.right, Offset(-1, 0)),
      'B9': (Seat.bottom, Offset(0, -1)),
      'A2': (Seat.left, Offset(1, 0)),
    };
    for (final entry in gates.entries) {
      final (seat, direction) = entry.value;
      final center = _designPoint(BoardGeometry.cellCenterForCoordinate(entry.key));
      final rect = Rect.fromCenter(center: center, width: cellSizePx, height: cellSizePx);
      canvas.drawRect(rect, Paint()..color = const Color(0xFFFF8800).withValues(alpha: 0.45));
      canvas.drawRect(rect, Paint()..color = const Color(0xFFFF8800)..style = PaintingStyle.stroke..strokeWidth = 2);

      final arrowLen = cellSizePx * 0.35;
      final tip = center + direction * arrowLen;
      final arrowPaint = Paint()
        ..color = AppTheme.seatColor(seat)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      canvas.drawLine(center, tip, arrowPaint);
      _label(canvas, 'GATE\n${entry.key}', center - Offset(0, cellSizePx * 0.35), color: const Color(0xFFFF8800));
    }
  }

  void _paintFinish(Canvas canvas, double cellSizePx) {
    final center = _designPoint(BoardGeometry.cellCenterForCoordinate('E5'));
    final r = cellSizePx * 0.4;
    final paint = Paint()
      ..color = const Color(0xFFFFEE00)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawLine(center - Offset(r, 0), center + Offset(r, 0), paint);
    canvas.drawLine(center - Offset(0, r), center + Offset(0, r), paint);
    canvas.drawCircle(center, r, paint);
    _label(canvas, 'FINISH E5', center + Offset(0, r + 10), color: const Color(0xFFFFEE00));
  }

  void _paintPlayerFrames(Canvas canvas) {
    final boardTopLeft = Offset(margin, margin);
    void frame(FrameAnchor anchor, bool visible, Seat seat, String label) {
      if (!visible) return;
      final center = boardTopLeft + PlayerFrameContract.centerFor(anchor, displayedBoardSize);
      final s = PlayerFrameContract.frameSize(displayedBoardSize);
      final rect = Rect.fromCenter(center: center, width: s, height: s);
      canvas.drawRect(
        rect,
        Paint()
          ..color = AppTheme.seatColor(seat)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      _label(canvas, label, center, color: AppTheme.seatColor(seat));
    }

    frame(FrameAnchor.top, profile.visibleSeats.top, Seat.top, 'TOP\nFRAME');
    frame(FrameAnchor.right, profile.visibleSeats.right, Seat.right, 'RIGHT\nFRAME');
    frame(FrameAnchor.bottom, profile.visibleSeats.bottom, Seat.bottom, 'BOTTOM\nFRAME');
    frame(FrameAnchor.left, profile.visibleSeats.left, Seat.left, 'LEFT\nFRAME');
  }

  void _paintPieceBoundingCircle(Canvas canvas, double cellSizePx) {
    final center = _designPoint(BoardGeometry.cellCenterForCoordinate('E9'));
    final r = PieceContract.normalSize(cellSizePx) / 2;
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = const Color(0xFFB600FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    _label(canvas, 'PIECE Ø', center - Offset(0, r + 10), color: const Color(0xFFB600FF));
  }

  void _paintCastTray(Canvas canvas, Size size) {
    final trayWidth = CastTrayContract.displayWidth(displayedBoardSize);
    final trayHeight = CastTrayContract.displayHeight(displayedBoardSize);
    final trayRect = Rect.fromLTWH(
      (size.width - trayWidth) / 2,
      size.height - trayHeight - 12,
      trayWidth,
      trayHeight,
    );
    canvas.drawRect(trayRect, Paint()..color = const Color(0xFF008080).withValues(alpha: 0.25));
    canvas.drawRect(
      trayRect,
      Paint()
        ..color = const Color(0xFF00FFCC)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    _label(canvas, 'CAST TRAY', Offset(trayRect.left + 4, trayRect.top - 12), color: const Color(0xFF00FFCC), align: TextAlign.left);

    var i = 1;
    for (final ratio in CastTrayContract.slotCenterRatios()) {
      final slotCenter = trayRect.topLeft + Offset(ratio.dx * trayWidth, ratio.dy * trayHeight);
      final slotSize = trayHeight * 0.7;
      final slotRect = Rect.fromCenter(center: slotCenter, width: slotSize, height: slotSize);
      canvas.drawRect(
        slotRect,
        Paint()
          ..color = const Color(0xFFFFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      _label(canvas, '$i', slotCenter, color: Colors.white);
      i++;
    }
  }

  void _label(Canvas canvas, String text, Offset center, {Color color = Colors.black, TextAlign align = TextAlign.center}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.black.withValues(alpha: 0.55),
        ),
      ),
      textAlign: align,
      textDirection: TextDirection.ltr,
    )..layout();
    final offset = align == TextAlign.left ? center : center - Offset(tp.width / 2, tp.height / 2);
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _CalibrationPainter oldDelegate) {
    return oldDelegate.displayedBoardSize != displayedBoardSize ||
        oldDelegate.margin != margin ||
        oldDelegate.profile != profile;
  }
}
