import 'dart:async';

import 'package:flutter/material.dart';

/// Subtle game-style entrance for a page's major elements: fade in, scale up
/// from ~0.95, and a small upward translate. [order] staggers siblings (0 =
/// first) a short beat apart. Purely a one-shot transform/opacity animation
/// on mount -- it never changes the child's layout size, so it cannot shift
/// anything around it.
class PopIn extends StatefulWidget {
  const PopIn({
    super.key,
    required this.child,
    this.order = 0,
    this.duration = const Duration(milliseconds: 350),
    this.stagger = const Duration(milliseconds: 70),
    this.beginScale = 0.95,
  });

  final Widget child;

  final int order;

  final Duration duration;

  final Duration stagger;

  final double beginScale;

  @override
  State<PopIn> createState() => _PopInState();
}

class _PopInState extends State<PopIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _fade;

  late final Animation<double> _scale;

  late final Animation<Offset> _slide;

  Timer? _startTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    final curved = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _fade = curved;
    _scale = Tween<double>(begin: widget.beginScale, end: 1.0).animate(curved);
    _slide = Tween<Offset>(
      begin: const Offset(0.0, 0.02),
      end: Offset.zero,
    ).animate(curved);
    // An explicit, cancellable Timer (rather than Future.delayed) so a
    // pending stagger delay can never fire -- or be left pending -- after
    // this widget is disposed (e.g. navigating away mid-stagger).
    _startTimer = Timer(widget.stagger * widget.order, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: SlideTransition(position: _slide, child: widget.child),
      ),
    );
  }
}
