import 'package:flutter/material.dart';
import 'package:tamtam/domain/models/rule_profile.dart';
import 'package:tamtam/domain/models/player_state.dart';
import 'package:tamtam/domain/models/seat.dart';
import 'package:tamtam/domain/models/game_state.dart';
import 'package:tamtam/presentation/screens/match_screen.dart';
import 'package:tamtam/presentation/widgets/pressable_scale.dart';
import 'package:tamtam/presentation/widgets/pop_in.dart';
import 'package:tamtam/presentation/widgets/tamtam_background.dart';
import 'package:tamtam/presentation/navigation/tamtam_page_route.dart';

/// Match Setup's only remaining job is Classic vs Blitz + Start. Format
/// (2P/4P/Bot) is already decided on Home and arrives via [gameType].
class MatchSetupScreen extends StatefulWidget {
  const MatchSetupScreen({super.key, this.gameType});

  final String? gameType;

  @override
  State<MatchSetupScreen> createState() {
    return _MatchSetupScreenState();
  }
}

class _MatchSetupScreenState extends State<MatchSetupScreen> {
  String? _selectedGameType;

  RuleProfile? _selectedProfile;

  String? _botConfig;

  @override
  void initState() {
    super.initState();
    _selectedGameType = widget.gameType ?? '2 Player';
    _selectedProfile = RuleProfile.classic();
    if (_selectedGameType == 'Play Bot') {
      _botConfig = '1v1';
    }
  }

  void _playGame() {
    if (!_isReadyToPlay()) {
      return;
    }
    final players = <PlayerState>[];
    int startProgress = _selectedProfile!.startProgress;
    if (_selectedGameType == '2 Player') {
      players.add(
        PlayerState(
          id: 'p1',
          name: 'Player 1',
          seat: Seat.bottom,
          kind: PlayerKind.human,
          progress: startProgress,
        ),
      );
      players.add(
        PlayerState(
          id: 'p2',
          name: 'Player 2',
          seat: Seat.top,
          kind: PlayerKind.human,
          progress: startProgress,
        ),
      );
    } else if (_selectedGameType == '4 Player') {
      players.add(
        PlayerState(
          id: 'p1',
          name: 'Player 1',
          seat: Seat.bottom,
          kind: PlayerKind.human,
          progress: startProgress,
        ),
      );
      players.add(
        PlayerState(
          id: 'p2',
          name: 'Player 2',
          seat: Seat.left,
          kind: PlayerKind.human,
          progress: startProgress,
        ),
      );
      players.add(
        PlayerState(
          id: 'p3',
          name: 'Player 3',
          seat: Seat.top,
          kind: PlayerKind.human,
          progress: startProgress,
        ),
      );
      players.add(
        PlayerState(
          id: 'p4',
          name: 'Player 4',
          seat: Seat.right,
          kind: PlayerKind.human,
          progress: startProgress,
        ),
      );
    } else if (_selectedGameType == 'Play Bot' || _selectedGameType == 'Bot') {
      if (_botConfig == '1v1') {
        players.add(
          PlayerState(
            id: 'p1',
            name: 'You (Player)',
            seat: Seat.bottom,
            kind: PlayerKind.human,
            progress: startProgress,
          ),
        );
        players.add(
          PlayerState(
            id: 'p2',
            name: 'TamBot AI',
            seat: Seat.top,
            kind: PlayerKind.bot,
            progress: startProgress,
          ),
        );
      } else {
        players.add(
          PlayerState(
            id: 'p1',
            name: 'You (Player)',
            seat: Seat.bottom,
            kind: PlayerKind.human,
            progress: startProgress,
          ),
        );
        players.add(
          PlayerState(
            id: 'p2',
            name: 'Bot North',
            seat: Seat.top,
            kind: PlayerKind.bot,
            progress: startProgress,
          ),
        );
        players.add(
          PlayerState(
            id: 'p3',
            name: 'Bot East',
            seat: Seat.right,
            kind: PlayerKind.bot,
            progress: startProgress,
          ),
        );
        players.add(
          PlayerState(
            id: 'p4',
            name: 'Bot West',
            seat: Seat.left,
            kind: PlayerKind.bot,
            progress: startProgress,
          ),
        );
      }
    }
    final gameState = GameState(
      players: players,
      ruleProfile: _selectedProfile!,
      activePlayerIndex: 0,
      phase: TurnPhase.waitingForCast,
    );
    Navigator.pushReplacement(
      context,
      tamTamRoute((context) => MatchScreen(initialState: gameState)),
    );
  }

  bool _isReadyToPlay() {
    if (_selectedGameType == null) {
      return false;
    }
    if (_selectedProfile == null) {
      return false;
    }
    if ((_selectedGameType == 'Play Bot' || _selectedGameType == 'Bot') &&
        _botConfig == null) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: TamTamBackground(
        child: SafeArea(
          child: Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final sideBySide = constraints.maxWidth >= 300.0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 56.0),
                        Expanded(
                          child: Center(
                            child: PopIn(
                              order: 0,
                              child: sideBySide
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Expanded(child: _buildRuleCard(RuleProfile.classic(), 'assets/setup/classic.png')),
                                        const SizedBox(width: 18.0),
                                        Expanded(child: _buildRuleCard(RuleProfile.blitz(), 'assets/setup/blitz.png')),
                                      ],
                                    )
                                  : Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 240.0,
                                          child: _buildRuleCard(RuleProfile.classic(), 'assets/setup/classic.png'),
                                        ),
                                        const SizedBox(height: 18.0),
                                        SizedBox(
                                          width: 240.0,
                                          child: _buildRuleCard(RuleProfile.blitz(), 'assets/setup/blitz.png'),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                        PopIn(order: 1, child: _buildStartButton()),
                        const SizedBox(height: 16.0),
                      ],
                    ),
                  );
                },
              ),
              Positioned(
                top: 4.0,
                right: 4.0,
                child: _CloseButton(onTap: () => Navigator.of(context).pop()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRuleCard(RuleProfile profile, String asset) {
    final isSelected = _selectedProfile?.mode == profile.mode;
    return PressableScale(
      onTap: () => setState(() => _selectedProfile = profile),
      child: AspectRatio(
        aspectRatio: 1,
        // classic.png / blitz.png already contain their frame, art, title,
        // and an empty checkbox recess in the top-right -- only the check
        // mark itself is drawn here, precisely inside that baked-in recess.
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(asset, fit: BoxFit.contain),
            if (isSelected)
              Align(
                // Align distributes free space around the child, so
                // centering a child of fractional size s at target fraction
                // f needs a = 2*(f - s/2)/(1 - s) - 1, not the naive 2f-1
                // (only exact for a zero-size child). Recess measured at
                // ~(0.84, 0.19) of the card, check-mark box size s=0.11.
                alignment: const Alignment(0.76, -0.70),
                child: FractionallySizedBox(
                  widthFactor: 0.11,
                  heightFactor: 0.11,
                  child: FittedBox(
                    child: Icon(Icons.check_rounded, color: const Color(0xFFFCE9BE)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    final ready = _isReadyToPlay();
    final button = Opacity(
      opacity: ready ? 1.0 : 0.5,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340.0),
        child: AspectRatio(
          aspectRatio: 1969 / 799,
          child: Image.asset('assets/setup/start.png', fit: BoxFit.contain),
        ),
      ),
    );
    if (!ready) {
      return button;
    }
    return PressableScale(onTap: _playGame, child: button);
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: const Padding(
        padding: EdgeInsets.all(10.0),
        child: Image(
          image: AssetImage('assets/setup/x-icon-lg.png'),
          width: 30.0,
          height: 30.0,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
