import 'package:flutter/material.dart';
import '../../domain/models/cast_result.dart';
import 'tamtam_cube.dart';

class CastTray extends StatefulWidget {
  final CastResult? lastCast;
  final VoidCallback? onCastPressed;
  final bool canCast;
  final Color activePlayerColor;
  final bool isAnimatingCubes;

  const CastTray({
    Key? key,
    this.lastCast,
    this.onCastPressed,
    required this.canCast,
    required this.activePlayerColor,
    required this.isAnimatingCubes,
  }) : super(key: key);

  @override
  State<CastTray> createState() => _CastTrayState();
}

class _CastTrayState extends State<CastTray> with SingleTickerProviderStateMixin {
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
    // Default faces if no cast yet
    final faces = widget.lastCast?.faces ?? List.filled(4, Face.white);
    
    return GestureDetector(
      onTap: widget.canCast ? widget.onCastPressed : null,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final pulseValue = _pulseController.value;
          
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.canCast
                    ? widget.activePlayerColor.withOpacity(0.5 + (0.5 * pulseValue))
                    : widget.activePlayerColor.withOpacity(0.3),
                width: widget.canCast ? 2 + (1 * pulseValue) : 2,
              ),
              boxShadow: [
                if (widget.canCast)
                  BoxShadow(
                    color: widget.activePlayerColor.withOpacity(0.15 * pulseValue),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: TamTamCube(
                        face: faces[index],
                        isAnimating: widget.isAnimatingCubes,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                if (widget.lastCast != null && !widget.isAnimatingCubes)
                  Text(
                    'Move ${widget.lastCast!.value}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                if (widget.lastCast == null || widget.isAnimatingCubes)
                  Text(
                    'TAP TO CAST',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      letterSpacing: 1.5,
                      color: widget.canCast 
                        ? widget.activePlayerColor 
                        : Colors.grey.shade400,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
