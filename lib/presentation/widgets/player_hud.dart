import 'package:flutter/material.dart';

class PlayerHud extends StatefulWidget {
  final String name;
  final Color color;
  final bool isActive;
  final bool isBot;

  const PlayerHud({
    super.key,
    required this.name,
    required this.color,
    required this.isActive,
    this.isBot = false,
  });

  @override
  State<PlayerHud> createState() => _PlayerHudState();
}

class _PlayerHudState extends State<PlayerHud> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isActive) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant PlayerHud oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isActive && oldWidget.isActive) {
      _pulseController.animateTo(0.0, duration: const Duration(milliseconds: 300));
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: widget.isActive ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color,
                    boxShadow: widget.isActive
                        ? [
                            BoxShadow(
                              color: widget.color.withOpacity(0.6),
                              blurRadius: 8,
                              spreadRadius: 2,
                            )
                          ]
                        : null,
                  ),
                  child: widget.isBot
                      ? const Center(
                          child: Icon(
                            Icons.smart_toy,
                            size: 10,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: 14,
              color: widget.isActive ? Colors.black87 : Colors.black54,
              fontWeight: widget.isActive ? FontWeight.bold : FontWeight.normal,
            ),
            child: Text(widget.name),
          ),
        ],
      ),
    );
  }
}
