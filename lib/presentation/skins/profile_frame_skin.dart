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
    id: 'default_frame',
    displayName: 'Default Frame',
    builder: (context) => DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
      ),
    ),
  );

  /// First test skin proving a real asset can drop into the frame slot.
  /// Falls back to [placeholder] if assets/skins/frames/custom_frame_01.png
  /// is missing -- see that folder's README for the expected artwork.
  static final customTest = ProfileFrameSkin(
    id: 'custom_frame_test',
    displayName: 'Custom Frame Test',
    builder: (context) => Image.asset(
      'assets/skins/frames/custom_frame_01.png',
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => placeholder.builder(context),
    ),
  );

  /// Final shared profile-frame ring, reused unchanged across Home and every
  /// gameplay HUD seat (see PlayerPortrait). The avatar is a separate layer
  /// underneath -- this asset is transparent at its center by design.
  static final tamtam = ProfileFrameSkin(
    id: 'tamtam_frame',
    displayName: 'TamTam Frame',
    builder: (context) => Image.asset(
      'assets/shared/profiles/profile_frame_default.png',
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => placeholder.builder(context),
    ),
  );

  static final List<ProfileFrameSkin> all = [tamtam, placeholder, customTest];
}
