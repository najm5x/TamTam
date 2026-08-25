import 'package:flutter/material.dart';

/// The match-exit confirmation dialog. Visually just exit.png with
/// yes_button.png / no_button.png overlaid -- both PNGs already contain
/// their own text, so nothing is rendered on top except the buttons
/// themselves. Returns true (confirm exit) or false/null (stay).
class PauseDialog extends StatelessWidget {
  const PauseDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 64.0),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/dialogs/exit.png', fit: BoxFit.contain),
            Align(
              alignment: const Alignment(0.0, 0.62),
              child: FractionallySizedBox(
                widthFactor: 0.8,
                child: Row(
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
              ),
            ),
          ],
        ),
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AspectRatio(
        aspectRatio: 887 / 605,
        child: Image.asset(asset, fit: BoxFit.contain),
      ),
    );
  }
}
