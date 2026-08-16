import 'package:flutter/material.dart';

/// Presentation-only cast-tray artwork on the 1000x240 canvas defined by
/// CastTrayContract. The tray art itself is neutral; the active player's
/// color is always a programmatic accent drawn on top, not a per-player
/// tray image.
class CastTraySkin {
  final String id;
  final String displayName;
  final WidgetBuilder backgroundBuilder;

  CastTraySkin({
    required this.id,
    required this.displayName,
    required this.backgroundBuilder,
  });

  static final placeholder = CastTraySkin(
    id: 'placeholder_tray',
    displayName: 'Placeholder Tray',
    backgroundBuilder: (context) => DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}
