import 'package:flutter/material.dart';
import 'package:tamtam/presentation/theme/app_theme.dart';
import 'package:tamtam/presentation/widgets/player_portrait.dart';

class PlayerHud extends StatelessWidget {
  const PlayerHud({
    super.key,
    required this.name,
    required this.color,
    required this.isActive,
    this.isBot = false,
  });

  final String name;

  final Color color;

  final bool isActive;

  final bool isBot;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 54.0,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        // No fill: the blue global app background shows through the chip's
        // interior, leaving only the stroke/accent as the readable frame.
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24.0),
        // Width stays fixed across active/inactive (only color changes) --
        // see cast_tray.dart's border comment: a BoxDecoration border width
        // becomes extra Container padding, so a width that changed with
        // isActive would nudge this chip's own footprint by a px on every
        // turn change.
        border: Border.all(
          color: isActive ? color : Colors.white.withValues(alpha: 0.45),
          width: 2.0,
        ),
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: color.withValues(alpha: 0.45),
              blurRadius: 10.0,
              offset: const Offset(0.0, 3.0),
            ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PlayerPortrait(size: 42.0, accentColor: color, isActive: isActive, isBot: isBot),
          const SizedBox(width: 8.0),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: 13.0,
              fontFamily: 'Plus Jakarta Sans',
              color: AppTheme.textLight,
              fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
              shadows: const [
                Shadow(color: Color(0x991B0F2E), blurRadius: 4.0, offset: Offset(0.0, 1.0)),
              ],
            ),
            child: Text(name),
          ),
        ],
      ),
    );
  }
}
