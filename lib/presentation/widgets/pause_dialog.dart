import 'package:flutter/material.dart';
import 'package:tamtam/presentation/widgets/pressable_scale.dart';

/// The match-exit confirmation dialog. exit.png is one separate panel; the
/// yes_button.png / no_button.png pair sits below it with a clear gap so the
/// buttons never overlap or feel attached to the card. Both PNGs already
/// contain their own text, so nothing else is rendered on top. Returns true
/// (confirm exit) or false/null (stay).
class PauseDialog extends StatelessWidget {
  const PauseDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 64.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Image.asset('assets/dialogs/exit.png', fit: BoxFit.contain),
          ),
          const SizedBox(height: 24.0),
          Row(
            children: [
              Expanded(
                child: _DialogButton(
                  asset: 'assets/dialogs/no_button.png',
                  onTap: () => Navigator.of(context).pop(false),
                ),
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: _DialogButton(
                  asset: 'assets/dialogs/yes_button.png',
                  onTap: () => Navigator.of(context).pop(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({required this.asset, required this.onTap});

  final String asset;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 887 / 605,
        child: Image.asset(asset, fit: BoxFit.contain),
      ),
    );
  }
}
