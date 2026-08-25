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
        color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(24.0),
        // Width stays fixed across active/inactive (only color changes) --
        // see cast_tray.dart's border comment: a BoxDecoration border width
        // becomes extra Container padding, so a width that changed with
        // isActive would nudge this chip's own footprint by a px on every
        // turn change.
        border: Border.all(
          color: isActive ? color : const Color(0x14000000),
          width: 2.0,
        ),
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: color.withValues(alpha: 0.25),
              blurRadius: 10.0,
              offset: const Offset(0.0, 3.0),
            )
          else
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4.0,
              offset: const Offset(0.0, 2.0),
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
              color: isActive ? AppTheme.primaryDark : AppTheme.textSecondary,
              fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
            ),
            child: Text(name),
          ),
        ],
      ),
    );
  }
}
