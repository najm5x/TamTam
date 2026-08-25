import 'package:flutter/material.dart';
import 'package:tamtam/domain/models/seat.dart';

class AppTheme {
  // Final presentation palette (board_tamtam_01.png / piece_*.png):
  // Top=Blue, Right=Red, Bottom=Yellow, Left=Green. Gameplay seat/route
  // logic is unaffected -- this only maps a seat to its display color.
  static const Color topPlayerColor = const Color(0xFF2979FF);

  static const Color rightPlayerColor = const Color(0xFFE53935);

  static const Color bottomPlayerColor = const Color(0xFFFBC02D);

  static const Color leftPlayerColor = const Color(0xFF43A047);

  static const Color boardBackground = const Color(0xFFFAF7F2);

  static const Color cellBorderColor = const Color(0x18000000);

  static const Color gridLineColor = const Color(0x15000000);

  static const Color centerCellColor = const Color(0xFFFEF3C7);

  static const Color safeCellColor = const Color(0xA000000);

  static const Color primaryDark = const Color(0xFF0F172A);

  static const Color primaryMid = const Color(0xFF1E293B);

  static const Color accent = const Color(0xFFF97316);

  static const Color accentLight = const Color(0xFFFBBF24);

  static const Color cardBg = const Color(0xFFFFFFFF);

  static const Color surfaceBg = const Color(0xFFF8FAFC);

  static const Color textPrimary = const Color(0xFF0F172A);

  static const Color textSecondary = const Color(0xFF64748B);

  static const Color textLight = const Color(0xFFFFFFFF);

  static const LinearGradient primaryGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: const [Color(0xFF0F172A), Color(0xFF1E293B)],
  );

  static const LinearGradient warmGradient = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: const [Color(0xFFFDFBF7), Color(0xFFF1F5F9)],
  );

  static const LinearGradient heroGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: const [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF4338CA)],
  );

  static const LinearGradient orangeGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: const [Color(0xFFFF7E5F), Color(0xFFFEB47B)],
  );

  static const LinearGradient tealGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: const [Color(0xFF06B6D4), Color(0xFF0D9488)],
  );

  static const LinearGradient purpleGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
  );

  static ThemeData get theme {
    const defaultFont = 'Plus Jakarta Sans';
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF3B82F6),
        primary: const Color(0xFF0F172A),
        secondary: const Color(0xFFF97316),
        surface: surfaceBg,
        brightness: Brightness.light,
      ),
      // Navy, not white: this is the fallback layer visible at any edge/gap
      // during a route transition (before/behind TamTamBackground's image),
      // so it must never read as a white flash.
      scaffoldBackgroundColor: primaryDark,
      fontFamily: defaultFont,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontFamily: defaultFont,
          fontSize: 18.0,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2.0,
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          textStyle: const TextStyle(
            fontFamily: defaultFont,
            fontWeight: FontWeight.w700,
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }

  static Color playerColor(String seat) {
    switch (seat) {
      case 'top':
        return topPlayerColor;
      case 'right':
        return rightPlayerColor;
      case 'bottom':
        return bottomPlayerColor;
      case 'left':
        return leftPlayerColor;
      default:
        return Colors.grey;
    }
  }

  static Color seatColor(Seat seat) {
    switch (seat) {
      case Seat.top:
        return topPlayerColor;
      case Seat.right:
        return rightPlayerColor;
      case Seat.bottom:
        return bottomPlayerColor;
      case Seat.left:
        return leftPlayerColor;
    }
  }
}
