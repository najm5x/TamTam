import 'dart:math';
import 'package:flutter/material.dart';
import '../../domain/models/cast_result.dart';

class TamTamCube extends StatefulWidget {
  final Face face;
  final bool isAnimating;

  const TamTamCube({
    Key? key,
    required this.face,
    this.isAnimating = false,
  }) : super(key: key);

  @override
  State<TamTamCube> createState() => _TamTamCubeState();
}

class _TamTamCubeState extends State<TamTamCube> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    if (widget.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(TamTamCube oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating != oldWidget.isAnimating) {
      if (widget.isAnimating) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double angleX = 0;
        double angleZ = 0;

        if (widget.isAnimating) {
          angleX = _controller.value * 2 * pi;
          angleZ = _controller.value * 2 * pi;
        }

        final topColor = widget.face == Face.white 
            ? const Color(0xFFFFFFF0) 
            : const Color(0xFF2D2D2D);

        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // perspective
            ..rotateX(angleX)
            ..rotateZ(angleZ),
          alignment: Alignment.center,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: topColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 2,
                  offset: const Offset(1, 2),
                ),
                BoxShadow(
                  color: const Color(0xFF9E9E9E), // Neutral grey for 3D depth
                  blurRadius: 0,
                  offset: const Offset(2, 4),
                ),
              ],
              border: Border.all(color: Colors.white24, width: 1),
            ),
          ),
        );
      },
    );
  }
}
