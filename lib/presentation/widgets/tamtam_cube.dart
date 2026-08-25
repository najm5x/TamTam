import 'dart:math';
import 'package:flutter/material.dart';
import '../../domain/models/cast_result.dart';
import '../skins/skin_catalog.dart';

class TamTamCube extends StatefulWidget {
  final Face face;
  final bool isAnimating;
  final double size;

  const TamTamCube({
    Key? key,
    required this.face,
    this.isAnimating = false,
    this.size = 44.0,
  }) : super(key: key);

  @override
  State<TamTamCube> createState() => _TamTamCubeState();
}

class _TamTamCubeState extends State<TamTamCube>
    with SingleTickerProviderStateMixin {
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
        double angleX = 0.0;
        double angleZ = 0.0;
        if (widget.isAnimating) {
          angleX = _controller.value * 2 * pi;
          angleZ = _controller.value * 2 * pi;
        }
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(angleX)
            ..rotateZ(angleZ),
          alignment: Alignment.center,
          origin: const Offset(0.0, 0.0),
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: SkinCatalog.defaultPack.dice.faceBuilder(context, widget.face),
          ),
        );
      },
    );
  }
}
