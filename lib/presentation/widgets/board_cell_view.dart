import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';
import '../../domain/models/seat.dart';

class BoardCellView extends StatelessWidget {
  final String coordinate;
  final Color? cellColor;
  final List<Seat> pieces;
  final Seat? gateForSeat; // If this cell is a gate, which player's gate
  final String? gateDirection; // 'down', 'left', 'up', 'right'
  final bool isPreFinish;
  final Color? preFinishColor;

  const BoardCellView({
    super.key,
    required this.coordinate,
    this.cellColor,
    this.pieces = const [],
    this.gateForSeat,
    this.gateDirection,
    this.isPreFinish = false,
    this.preFinishColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cellColor ?? const Color(0xFFFAF6F0),
        border: Border.all(
          color: AppTheme.cellBorderColor,
          width: 0.5,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pre-finish subtle tint
          if (isPreFinish && preFinishColor != null)
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: preFinishColor!.withOpacity(0.35),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          // Gate arrow
          if (gateForSeat != null && gateDirection != null)
            _buildGateArrow(),
          // Pieces
          if (pieces.isNotEmpty)
            _buildPieces(),
        ],
      ),
    );
  }

  Widget _buildGateArrow() {
    final color = _seatColor(gateForSeat!).withOpacity(0.35);
    double angle = 0;
    switch (gateDirection) {
      case 'down':
        angle = math.pi / 2;
        break;
      case 'left':
        angle = math.pi;
        break;
      case 'up':
        angle = -math.pi / 2;
        break;
      case 'right':
        angle = 0;
        break;
    }
    return Transform.rotate(
      angle: angle,
      child: Icon(
        Icons.arrow_forward_rounded,
        size: 14,
        color: color,
      ),
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
    final color = _seatColor(seat);
    return LayoutBuilder(
      builder: (context, constraints) {
        // Target 65% of cell width for single piece, 45% for stacked
        final double size = small
            ? constraints.maxWidth * 0.45
            : constraints.maxWidth * 0.65;

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.0),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _seatColor(Seat seat) {
    switch (seat) {
      case Seat.top:
        return AppTheme.topPlayerColor;
      case Seat.right:
        return AppTheme.rightPlayerColor;
      case Seat.bottom:
        return AppTheme.bottomPlayerColor;
      case Seat.left:
        return AppTheme.leftPlayerColor;
    }
  }
}
