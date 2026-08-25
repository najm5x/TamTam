import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Presentation-only board artwork. A skin may decorate the 1080x1080
/// canvas (background/foreground layers) but never defines cell centers,
/// Homes/Gates/Finish, or gate arrows -- those stay programmatic and come
/// from BoardGeometry / VisualLayoutContract so the bitmap is never used
/// as hit-testing or movement truth.
class BoardSkin {
  final String id;
  final String displayName;
  final WidgetBuilder backgroundBuilder;
  final WidgetBuilder? foregroundBuilder;

  BoardSkin({
    required this.id,
    required this.displayName,
    required this.backgroundBuilder,
    this.foregroundBuilder,
  });

  static final placeholder = BoardSkin(
    id: 'default_board',
    displayName: 'Default Board',
    backgroundBuilder: (context) => Container(color: AppTheme.boardBackground),
  );

  /// assets/skins/boards/custom_board_01.png is a 1080x1080 PNG -- an exact
  /// match for the board-layout contract's canvas, so BoxFit.fill is correct
  /// here (no cropping/letterboxing/distortion since source and target are
  /// both that exact square). Falls back to [placeholder] if the asset is
  /// missing.
  static final custom = BoardSkin(
    id: 'custom_board',
    displayName: 'Custom Board',
    backgroundBuilder: (context) => Image.asset(
      'assets/skins/boards/custom_board_01.png',
      fit: BoxFit.fill,
      errorBuilder: (context, error, stackTrace) => placeholder.backgroundBuilder(context),
    ),
  );

  /// assets/skins/boards/board_tamtam_01.png is the final board art: a
  /// 1080x1080 PNG that already bakes in Home fills, gate arrows, and the
  /// Finish ornament for the palette in AppTheme.seatColor (Top=Blue,
  /// Right=Red, Bottom=Yellow, Left=Green). BoardWidget/BoardCellView no
  /// longer draw those overlays programmatically -- see their headers.
  static final tamtam = BoardSkin(
    id: 'tamtam_board',
    displayName: 'TamTam Board',
    backgroundBuilder: (context) => Image.asset(
      'assets/skins/boards/board_tamtam_01.png',
      fit: BoxFit.fill,
      errorBuilder: (context, error, stackTrace) => placeholder.backgroundBuilder(context),
    ),
  );

  static final List<BoardSkin> all = [tamtam, placeholder, custom];
}
