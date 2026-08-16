import 'package:flutter/material.dart';
import '../../domain/models/player_state.dart';

class PlayerCard extends StatelessWidget {
  final PlayerState player;
  final bool isActive;

  const PlayerCard({
    super.key,
    required this.player,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: isActive ? Colors.blue.shade50 : Colors.transparent,
        border: Border.all(color: isActive ? Colors.blue : Colors.grey.shade300, width: 2),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            player.kind == PlayerKind.human ? Icons.person : Icons.computer,
            color: isActive ? Colors.blue : Colors.grey,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${player.name} (${player.seat.name})', 
                style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.normal),
              ),
              Text(
                'Progress: ${player.progress}', 
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
