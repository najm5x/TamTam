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
    id: 'default_piece',
    displayName: 'Default Piece',
    builder: (context, seat) => DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.seatColor(seat),
        border: Border.all(color: Colors.white, width: 2),
      ),
    ),
  );

  /// assets/skins/pieces/custom_piece_01.png is a finished, fully-shaded gem
  /// render (gold frame, gradient, highlights) -- not a flat/white shape
  /// meant for tinting. Applying AppTheme.seatColor via a ColorFilter would
  /// wash out that baked-in art, so this skin renders it untinted and does
  /// not vary by seat. Falls back to [placeholder] (which does tint) if
  /// the asset is missing.
  static final custom = PieceSkin(
    id: 'custom_piece',
    displayName: 'Custom Piece',
    builder: (context, seat) => Image.asset(
      'assets/skins/pieces/custom_piece_01.png',
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => placeholder.builder(context, seat),
    ),
  );

  /// Final seat-mapped pieces: Top=blue, Right=red, Bottom=yellow, Left=green
  /// (see AppTheme.seatColor). Each PNG is already fully shaded per-seat
  /// artwork, so -- like [custom] -- it renders untinted.
  static final tamtam = PieceSkin(
    id: 'tamtam_piece',
    displayName: 'TamTam Piece',
    builder: (context, seat) {
      final asset = switch (seat) {
        Seat.top => 'assets/skins/pieces/piece_blue.png',
        Seat.right => 'assets/skins/pieces/piece_red.png',
        Seat.bottom => 'assets/skins/pieces/piece_yellow.png',
        Seat.left => 'assets/skins/pieces/piece_green.png',
      };
      return Image.asset(
        asset,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => placeholder.builder(context, seat),
      );
    },
  );

  static final List<PieceSkin> all = [tamtam, placeholder, custom];
}
