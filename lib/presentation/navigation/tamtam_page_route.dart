import 'package:flutter/material.dart';

/// Fade + slight scale page transition used for every major TamTam route
/// instead of the platform default. Both outgoing and incoming pages stay
/// full-bleed and opaque throughout (no slide-off that could expose a route
/// background at the edge), which is what keeps the TamTam blue background
/// visible behind the transition instead of a white flash.
Route<T> tamTamRoute<T>(WidgetBuilder builder) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    opaque: true,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.97, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}
