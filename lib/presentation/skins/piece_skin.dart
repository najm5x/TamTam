import 'package:flutter/material.dart';
import '../../domain/models/seat.dart';
import '../theme/app_theme.dart';

/// Presentation-only piece artwork on the 512x512 canvas defined by
/// PieceContract. The logical anchor is always the current canonical
/// cell's center; changing this skin must never affect route coordinates.
class PieceSkin {
  final String id;
  final String displayName;
  final Widget Function(BuildContext context, Seat seat) builder;

  PieceSkin({
    required this.id,
    required this.displayName,
    required this.builder,
  });

  static final placeholder = PieceSkin(
    id: 'placeholder_piece',
    displayName: 'Placeholder Piece',
    builder: (context, seat) => DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.seatColor(seat),
        border: Border.all(color: Colors.white, width: 2),
      ),
    ),
  );
}
