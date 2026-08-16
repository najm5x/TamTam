import 'package:flutter/material.dart';

/// Presentation-only profile-frame artwork on the 512x512 canvas defined by
/// PlayerFrameContract. Player names are always rendered by Flutter text on
/// top of this -- a skin must never bake a name/username into its art.
class ProfileFrameSkin {
  final String id;
  final String displayName;
  final WidgetBuilder builder;

  ProfileFrameSkin({
    required this.id,
    required this.displayName,
    required this.builder,
  });

  static final placeholder = ProfileFrameSkin(
    id: 'placeholder_frame',
    displayName: 'Placeholder Frame',
    builder: (context) => DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
      ),
    ),
  );
}
