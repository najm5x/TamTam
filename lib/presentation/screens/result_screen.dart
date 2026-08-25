import 'package:flutter/material.dart';
import 'package:tamtam/domain/models/game_state.dart';
import 'package:tamtam/presentation/screens/match_screen.dart';
import 'package:tamtam/presentation/widgets/tamtam_background.dart';
import 'package:tamtam/presentation/widgets/player_portrait.dart';

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

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  late final Animation<double> _fadeAnimation;

  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

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
      MaterialPageRoute(builder: (_) => MatchScreen(initialState: freshState)),
    );
  }

  void _goHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TamTamBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AspectRatio(
                          aspectRatio: 1.0,
                          child: _WinnerBoard(
                            winnerName: widget.winnerName,
                            winnerColor: widget.winnerColor,
                          ),
                        ),
                        const SizedBox(height: 28.0),
                        _ImageButton(
                          key: const Key('resultScreenRematchButton'),
                          asset: 'assets/victory/button_rematch.png',
                          onTap: _rematch,
                        ),
                        const SizedBox(height: 14.0),
                        _ImageButton(
                          key: const Key('resultScreenHomeButton'),
                          asset: 'assets/victory/button_home.png',
                          onTap: _goHome,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The custom winner-board art plus its two runtime overlays. Placement
/// ratios are normalized to the board's own width/height per the product
/// spec (profile center ~0.50,0.355; name center ~0.50,0.585) so they track
/// the board at any screen size without touching the baked-in artwork.
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
          alignment: const Alignment(0.0, -0.29), // y=0.355 of board height
          child: FractionallySizedBox(
            widthFactor: 0.29,
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
        Align(
          alignment: const Alignment(0.0, 0.17), // y=0.585 of board height
          child: FractionallySizedBox(
            widthFactor: 0.53,
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AspectRatio(
        aspectRatio: 3.0,
        child: Image.asset(asset, fit: BoxFit.contain),
      ),
    );
  }
}
