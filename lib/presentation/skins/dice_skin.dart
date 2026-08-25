import 'package:flutter/material.dart';
import '../../domain/models/cast_result.dart';

/// Presentation-only TamTam cube artwork on the 512x512 canvas defined by
/// DiceSkinContract. Always a binary White/Black object -- never numeric
/// pips -- and never a source of cast probability, which stays entirely
/// domain-owned (see CastGenerator).
class DiceSkin {
  final String id;
  final String displayName;
  final Widget Function(BuildContext context, Face face) faceBuilder;

  DiceSkin({
    required this.id,
    required this.displayName,
    required this.faceBuilder,
  });

  static final placeholder = DiceSkin(
    id: 'placeholder_dice',
    displayName: 'Placeholder Cube',
    faceBuilder: (context, face) => DecoratedBox(
      decoration: BoxDecoration(
        color: face == Face.white ? Colors.white : const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1A1A2E), width: 1.5),
      ),
    ),
  );

  /// Final binary TamTam cube: cube_white.png / cube_black.png. Still just
  /// two faces -- no pips, no numeric result -- see DiceSkinContract.
  static final tamtam = DiceSkin(
    id: 'tamtam_dice',
    displayName: 'TamTam Cube',
    faceBuilder: (context, face) {
      final asset = face == Face.white
          ? 'assets/skins/cubes/cube_white.png'
          : 'assets/skins/cubes/cube_black.png';
      return Image.asset(
        asset,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => placeholder.faceBuilder(context, face),
      );
    },
  );
}
