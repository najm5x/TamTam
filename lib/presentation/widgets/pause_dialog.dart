import 'package:flutter/material.dart';

class PauseDialog extends StatelessWidget {
  const PauseDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Game Paused'),
      content: const Text('Do you want to abandon the current match?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false), // return false for abandon
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // pop dialog then pop match screen
            Navigator.of(context).pop(true);
          },
          child: const Text('Abandon', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
