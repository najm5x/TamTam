import 'package:flutter/material.dart';
import 'package:tamtam/domain/models/game_state.dart';
import 'package:tamtam/presentation/screens/match_screen.dart';
import 'package:tamtam/presentation/widgets/tamtam_background.dart';
import 'package:tamtam/presentation/widgets/player_portrait.dart';
import 'package:tamtam/presentation/widgets/pressable_scale.dart';
import 'package:tamtam/presentation/widgets/pop_in.dart';
import 'package:tamtam/presentation/widgets/victory_celebration.dart';
import 'package:tamtam/presentation/navigation/tamtam_page_route.dart';

/// Victory screen: the custom winner-board asset (blue portrait circle +
/// ivory name plaque + baked-in WINNER art) is the entire visual, with only
/// the winner's live profile/name overlaid at runtime and the two custom
/// button assets below it. No separate heading, stats, or cards -- see the
/// "complete simplification" product decision.
class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    required this.winnerName,
    required this.winnerColor,
    required this.finishedState,
  });

  final String winnerName;

  final Color winnerColor;

  final GameState finishedState;

  @override
  State<ResultScreen> createState() {
    return _ResultScreenState();
  }
}

class _ResultScreenState extends State<ResultScreen> {
  // Unchanged rematch semantics: same rule profile/seats/roles, everyone
  // reset to mode start, winner/extra-cast state cleared.
  void _rematch() {
    final original = widget.finishedState;
    final profile = original.ruleProfile;
    final freshPlayers = original.players
        .map(
          (p) => p.copyWith(progress: profile.startProgress, isWinner: false),
        )
        .toList();
    final freshState = GameState(
      players: freshPlayers,
      activePlayerIndex: 0,
      ruleProfile: profile,
      phase: TurnPhase.waitingForCast,
      winnerId: null,
      extraCastsRemaining: 0,
    );
    Navigator.of(context).pushReplacement(
      tamTamRoute((_) => MatchScreen(initialState: freshState)),
    );
  }

  void _goHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: TamTamBackground(
        child: Stack(
          children: [
            const Positioned.fill(child: VictoryCelebration()),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PopIn(
                          order: 0,
                          child: AspectRatio(
                            aspectRatio: 1.0,
                            child: _WinnerBoard(
                              winnerName: widget.winnerName,
                              winnerColor: widget.winnerColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28.0),
                        PopIn(
                          order: 3,
                          child: _ImageButton(
                            key: const Key('resultScreenRematchButton'),
                            asset: 'assets/victory/button_rematch.png',
                            onTap: _rematch,
                          ),
                        ),
                        const SizedBox(height: 14.0),
                        PopIn(
                          order: 4,
                          child: _ImageButton(
                            key: const Key('resultScreenHomeButton'),
                            asset: 'assets/victory/button_home.png',
                            onTap: _goHome,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The custom winner-board art plus its two runtime overlays. Placement
/// ratios are normalized to the board's own width/height, measured directly
/// against assets/victory/winner_board.png (blue portrait circle center
/// ~0.50,0.355 / diameter ~0.30; ivory name plaque center ~0.50,0.56) so
/// they track the board at any screen size without touching the baked-in
/// artwork.
class _WinnerBoard extends StatelessWidget {
  const _WinnerBoard({required this.winnerName, required this.winnerColor});

  final String winnerName;

  final Color winnerColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        Image.asset('assets/victory/winner_board.png', fit: BoxFit.contain),
        Align(
          alignment: const Alignment(0.0, -0.288), // y=0.356 of board height
          child: PopIn(
            order: 1,
            child: FractionallySizedBox(
              // Outer frame diameter: sized to almost fill the art's blue
              // circle (diameter ~0.30 of board width), leaving a small
              // clean rim -- see class doc for the measured circle bounds.
              widthFactor: 0.34,
              child: AspectRatio(
                aspectRatio: 1.0,
                child: LayoutBuilder(
                  builder: (context, constraints) => PlayerPortrait(
                    size: constraints.maxWidth,
                    accentColor: winnerColor,
                  ),
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: const Alignment(0.0, 0.122), // y=0.561 of board height
          child: PopIn(
            order: 2,
            child: FractionallySizedBox(
              widthFactor: 0.48,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  winnerName,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 30.0,
                    letterSpacing: 0.5,
                    color: Color(0xFF3B0A14),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A custom button PNG used as-is for both its visual and its tap target --
/// the entire visible asset is tappable, no separate Flutter button chrome.
class _ImageButton extends StatelessWidget {
  const _ImageButton({super.key, required this.asset, required this.onTap});

  final String asset;

  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 3.0,
        child: Image.asset(asset, fit: BoxFit.contain),
      ),
    );
  }
}
