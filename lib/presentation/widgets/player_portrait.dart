import 'package:flutter/material.dart';
import '../skins/profile_frame_skin.dart';
import '../skins/skin_selection.dart';

/// Shared avatar+frame portrait reused by both the Home header and every
/// gameplay PlayerHud seat (see section 12/19: one shared asset pair, never
/// separate Home-only / gameplay-only versions). The avatar sits underneath
/// the frame skin's transparent center; an active seat gets a seat-colored
/// glow drawn externally as a pulse, never a recolored frame asset.
class PlayerPortrait extends StatefulWidget {
  const PlayerPortrait({
    super.key,
    required this.size,
    required this.accentColor,
    this.isActive = false,
    this.isBot = false,
  });

  final double size;
  final Color accentColor;
  final bool isActive;
  final bool isBot;

  @override
  State<PlayerPortrait> createState() => _PlayerPortraitState();
}

class _PlayerPortraitState extends State<PlayerPortrait>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    if (widget.isActive) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PlayerPortrait oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isActive && oldWidget.isActive) {
      _pulseController.animateTo(0.0, duration: const Duration(milliseconds: 250));
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulse = widget.isActive ? _pulseController.value : 0.0;
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: widget.accentColor.withValues(alpha: 0.35 + 0.25 * pulse),
                      blurRadius: size * (0.22 + 0.08 * pulse),
                      spreadRadius: size * 0.02,
                    ),
                  ]
                : null,
          ),
          child: child,
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipOval(
            child: SizedBox(
              width: size * 0.78,
              height: size * 0.78,
              child: Image.asset(
                'assets/shared/profiles/default_avatar.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: widget.accentColor.withValues(alpha: 0.25),
                ),
              ),
            ),
          ),
          ValueListenableBuilder<ProfileFrameSkin>(
            valueListenable: SkinSelection.frame,
            builder: (context, frameSkin, _) => SizedBox(
              width: size,
              height: size,
              child: frameSkin.builder(context),
            ),
          ),
          if (widget.isBot)
            Positioned(
              right: -size * 0.02,
              bottom: -size * 0.02,
              child: Container(
                width: size * 0.34,
                height: size * 0.34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.accentColor,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Icon(
                  Icons.smart_toy_rounded,
                  size: size * 0.2,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
