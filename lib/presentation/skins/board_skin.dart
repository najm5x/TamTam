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
    id: 'placeholder_board',
    displayName: 'Placeholder Board',
    backgroundBuilder: (context) => Container(color: AppTheme.boardBackground),
  );
}
