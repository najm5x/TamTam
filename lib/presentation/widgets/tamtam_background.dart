import 'package:flutter/material.dart';

/// Shared global app background (home_background.png), reused on Home,
/// Match Setup, Match, and Result so every primary screen shares one visual
/// backdrop instead of duplicating the same Image.asset/BoxFit.cover setup.
/// Never used in place of the board itself.
class TamTamBackground extends StatelessWidget {
  const TamTamBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/home/home_background.png', fit: BoxFit.cover),
        child,
      ],
    );
  }
}
