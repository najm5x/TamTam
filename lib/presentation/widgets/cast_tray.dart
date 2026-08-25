import 'package:flutter/material.dart';
import 'package:tamtam/domain/models/cast_result.dart';
import 'package:tamtam/presentation/widgets/tamtam_cube.dart';
import 'package:tamtam/presentation/skins/skin_catalog.dart';
import 'package:tamtam/presentation/layout/visual_layout_contract.dart';

/// The four resolved cubes are the cast presentation -- no separate numeric
/// result label is shown (section 15). The tray's own art (neutral
/// gold/burgundy, four baked-in recesses) is never recolored; the active
/// player's color is only ever an externally-drawn glow/border.
class CastTray extends StatefulWidget {
  const CastTray({
    super.key,
    this.lastCast,
    required this.onCastPressed,
    required this.canCast,
    required this.activePlayerColor,
    required this.isAnimatingCubes,
  });

  final CastResult? lastCast;

  final void Function() onCastPressed;

  final bool canCast;

  final Color activePlayerColor;

  final bool isAnimatingCubes;

  @override
  State<CastTray> createState() {
    return _CastTrayState();
  }
}

class _CastTrayState extends State<CastTray>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    if (widget.canCast) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(CastTray oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.canCast != oldWidget.canCast) {
      if (widget.canCast) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final faces = widget.lastCast?.faces ?? List.filled(4, Face.white);
    final trayBackground = SkinCatalog.defaultPack.castTray.backgroundBuilder;
    return GestureDetector(
      onTap: widget.canCast ? widget.onCastPressed : null,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final pulseValue = _pulseController.value;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [
                    if (widget.canCast)
                      BoxShadow(
                        color: widget.activePlayerColor.withValues(
                          alpha: 0.35 + (0.25 * pulseValue),
                        ),
                        blurRadius: 16.0 + (6.0 * pulseValue),
                        spreadRadius: 1.0 + (1.0 * pulseValue),
                      ),
                  ],
                  // Border width stays constant regardless of canCast --
                  // only its color animates to/from transparent. A
                  // BoxDecoration's border width becomes extra Container
                  // padding (Container._paddingIncludingDecoration), so a
                  // width that toggled 0<->2.0 would shrink/grow the tray's
                  // rendered footprint by a few px right as casting starts,
                  // reflowing the Expanded board above it in the match
                  // layout Column. Keeping the width fixed keeps that
                  // footprint -- and everything above it -- pixel-stable.
                  border: Border.all(
                    color: widget.canCast
                        ? widget.activePlayerColor.withValues(
                            alpha: 0.5 + (0.5 * pulseValue),
                          )
                        : Colors.transparent,
                    width: 2.0,
                  ),
                ),
                child: AspectRatio(
                  aspectRatio: CastTrayContract.aspectRatio,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        trayBackground(context),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final trayWidth = constraints.maxWidth;
                            // The art's four recesses sit inset from the two
                            // corner diamond ornaments -- evenly spacing
                            // cubes across the full tray width would push
                            // the outer two onto those ornaments.
                            final cubeSize = trayWidth * 0.15;
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: trayWidth * 0.19,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: List.generate(
                                  4,
                                  (index) => TamTamCube(
                                    face: faces[index],
                                    isAnimating: widget.isAnimatingCubes,
                                    size: cubeSize,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
