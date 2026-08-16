import 'package:flutter/material.dart';
import '../../domain/models/seat.dart';

class AppTheme {
  // Player colors
  static const Color topPlayerColor = Color(0xFF4A90D9);       // blue
  static const Color rightPlayerColor = Color(0xFF967E96);     // muted purple
  static const Color bottomPlayerColor = Color(0xFF8B9E90);    // sage green
  static const Color leftPlayerColor = Color(0xFF5BA4A4);      // teal

  // Board colors
  static const Color boardBackground = Color(0xFFFAF6F0);     // warm cream
  static const Color cellBorderColor = Color(0x18000000);      // very subtle
  static const Color gridLineColor = Color(0x15000000);        // subtle grid
  static const Color centerCellColor = Color(0xFFFDF5E6);      // soft cream for E5
  static const Color safeCellColor = Color(0x08000000);        // barely visible
  
  // UI Colors
  static const Color primaryDark = Color(0xFF1A1A2E);         // deep navy
  static const Color primaryMid = Color(0xFF16213E);          // mid navy
  static const Color accent = Color(0xFFF4A261);              // warm orange accent
  static const Color accentLight = Color(0xFFF7C873);         // light gold
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color surfaceBg = Color(0xFFF8F6F4);           // warm off-white
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFFFFFFFF);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
  );
  
  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFF8F0), Color(0xFFF8F6F4)],
  );
  
  static Color playerColor(String seat) {
    switch (seat) {
      case 'top': return topPlayerColor;
      case 'right': return rightPlayerColor;
      case 'bottom': return bottomPlayerColor;
      case 'left': return leftPlayerColor;
      default: return Colors.grey;
    }
  }

  static Color seatColor(Seat seat) {
    switch (seat) {
      case Seat.top: return topPlayerColor;
      case Seat.right: return rightPlayerColor;
      case Seat.bottom: return bottomPlayerColor;
      case Seat.left: return leftPlayerColor;
    }
  }
  
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1A1A2E),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: surfaceBg,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
