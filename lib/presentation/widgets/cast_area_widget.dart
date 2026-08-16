import 'package:flutter/material.dart';
import '../../domain/models/cast_result.dart';

class CastAreaWidget extends StatelessWidget {
  final CastResult? lastCast;
  final VoidCallback? onCastPressed;
  final bool canCast;

  const CastAreaWidget({
    super.key,
    this.lastCast,
    this.onCastPressed,
    this.canCast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (lastCast != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: lastCast!.faces.map((f) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: f == Face.white ? Colors.white : Colors.black,
                  border: Border.all(color: Colors.grey),
                ),
              );
            }).toList(),
          )
        else
          const SizedBox(height: 32),
        if (lastCast != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text('Move ${lastCast!.value}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: canCast ? onCastPressed : null,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text('CAST', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
