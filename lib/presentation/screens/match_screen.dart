import 'package:flutter/material.dart';
import 'package:tamtam/domain/models/game_state.dart';
import 'package:tamtam/domain/engine/cast_generator.dart';
import 'package:tamtam/domain/models/cast_result.dart';
import 'package:tamtam/domain/models/seat.dart';
import 'package:tamtam/domain/models/player_state.dart';
import 'package:tamtam/domain/models/rule_profile.dart';
import 'package:tamtam/presentation/theme/app_theme.dart';
import 'package:tamtam/domain/engine/tamtam_engine.dart';
import 'package:tamtam/domain/models/game_event.dart';
import 'package:tamtam/presentation/screens/result_screen.dart';
import 'package:tamtam/presentation/widgets/pause_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:tamtam/presentation/widgets/dev_overlay.dart';
import 'package:tamtam/presentation/widgets/player_hud.dart';
import 'package:tamtam/presentation/widgets/board_widget.dart';
import 'package:tamtam/presentation/widgets/cast_tray.dart';
import 'package:tamtam/presentation/widgets/tamtam_background.dart';
import 'package:tamtam/presentation/layout/visual_layout_contract.dart';
import 'package:tamtam/presentation/screens/settings_screen.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({this.initialState, this.castGenerator, super.key});

  final GameState? initialState;

  final CastGenerator? castGenerator;

  @override
  State<MatchScreen> createState() {
    return _MatchScreenState();
  }
}

class _MatchScreenState extends State<MatchScreen>
    with TickerProviderStateMixin {
  late GameState _gameState;

  late final CastGenerator _castGenerator;

  CastResult? _lastCastResult;

  bool _devModeVisible = false;

  bool _isAnimating = false;

  Seat? _animatingSeat;

  String? _animatingCoord;

  bool _isCubeAnimating = false;

  bool _showCaptureEffect = false;

  bool _showExtraCast = false;

  @override
  void initState() {
    super.initState();
    _castGenerator = widget.castGenerator ?? FairBinaryCastGenerator();
    _gameState =
        widget.initialState ??
        GameState(
          players: [
            const PlayerState(
              id: 'p1',
              name: 'Player 1',
              seat: Seat.bottom,
              kind: PlayerKind.human,
              progress: 0,
            ),
            const PlayerState(
              id: 'p2',
              name: 'Player 2',
              seat: Seat.top,
              kind: PlayerKind.human,
              progress: 0,
            ),
          ],
          activePlayerIndex: 0,
          ruleProfile: RuleProfile.classic(),
          phase: TurnPhase.waitingForCast,
        );
    _checkBotTurn();
  }

  void _checkBotTurn() {
    if (_gameState.phase != TurnPhase.waitingForCast) {
      return;
    }
    final active = _gameState.activePlayer;
    if (active.kind == PlayerKind.bot) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) {
          return;
        }
        _performCast();
      });
    }
  }

  Duration _stepDuration(int moveLength) {
    if (moveLength <= 6) {
      return const Duration(milliseconds: 100);
    }
    if (moveLength <= 16) {
      return const Duration(milliseconds: 75);
    }
    return const Duration(milliseconds: 60);
  }

  Color _activePlayerColor() {
    final seat = _gameState.activePlayer.seat;
    switch (seat) {
      case Seat.top:
        return AppTheme.topPlayerColor;
      case Seat.right:
        return AppTheme.rightPlayerColor;
      case Seat.bottom:
        return AppTheme.bottomPlayerColor;
      case Seat.left:
        return AppTheme.leftPlayerColor;
    }
  }

  void _performCast([CastResult? forcedCast]) {
    if (_gameState.phase != TurnPhase.waitingForCast ||
        _isAnimating ||
        _isCubeAnimating) {
      return;
    }
    final castResult = forcedCast ?? _castGenerator.generate();
    final activePlayer = _gameState.activePlayer;
    final transition = TamTamEngine.apply(_gameState, RequestCast(castResult));
    List<String>? movementPath;
    PieceCaptured? captureEvent;
    bool hasExtraCast = false;
    for (final event in transition.events) {
      if (event is PieceMovementPlanned) {
        movementPath = event.path;
      }
      if (event is PieceCaptured) {
        captureEvent = event;
      }
      if (event is ExtraCastGranted) {
        hasExtraCast = true;
      }
    }
    setState(() {
      _isCubeAnimating = true;
    });
    Future.delayed(const Duration(milliseconds: 650), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _isCubeAnimating = false;
        _lastCastResult = castResult;
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) {
          return;
        }
        if (movementPath != null && movementPath!.isNotEmpty) {
          _animateMovement(
            seat: activePlayer.seat,
            path: movementPath!,
            castValue: castResult.value,
            finalState: transition.state,
            captureEvent: captureEvent,
            hasExtraCast: hasExtraCast,
          );
        } else {
          setState(() {
            _gameState = transition.state;
          });
          _afterMovement(hasExtraCast: false);
        }
      });
    });
  }

  Future<void> _animateMovement({
    required Seat seat,
    required List<String> path,
    required int castValue,
    required GameState finalState,
    PieceCaptured? captureEvent,
    required bool hasExtraCast,
  }) async {
    setState(() {
      _isAnimating = true;
      _animatingSeat = seat;
    });
    final duration = _stepDuration(castValue);
    for (final coord in path) {
      if (!mounted) {
        return;
      }
      setState(() => _animatingCoord = coord);
      await Future.delayed(duration);
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _animatingSeat = null;
      _animatingCoord = null;
      _isAnimating = false;
      _gameState = finalState;
    });
    if (captureEvent != null) {
      setState(() => _showCaptureEffect = true);
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) {
        return;
      }
      setState(() => _showCaptureEffect = false);
    }
    if (hasExtraCast) {
      setState(() => _showExtraCast = true);
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) {
        return;
      }
      setState(() => _showExtraCast = false);
    }
    _afterMovement(hasExtraCast: hasExtraCast);
  }

  void _afterMovement({required bool hasExtraCast}) {
    if (!mounted) {
      return;
    }
    if (_gameState.phase == TurnPhase.matchFinished) {
      _navigateToResult();
      return;
    }
    if (_gameState.phase == TurnPhase.turnFinished ||
        _gameState.phase == TurnPhase.animatingMove) {
      final nextTrans = TamTamEngine.apply(_gameState, NextTurn());
      setState(() => _gameState = nextTrans.state);
      _checkBotTurn();
    }
  }

  void _navigateToResult() {
    final finishedState = _gameState;
    final winner = finishedState.players.firstWhere(
      (p) => p.isWinner,
      orElse: () => finishedState.activePlayer,
    );
    final winnerColor = _seatColor(winner.seat);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            winnerName: winner.name,
            winnerColor: winnerColor,
            finishedState: finishedState,
          ),
        ),
      );
    });
  }

  Color _seatColor(Seat seat) {
    switch (seat) {
      case Seat.top:
        return AppTheme.topPlayerColor;
      case Seat.right:
        return AppTheme.rightPlayerColor;
      case Seat.bottom:
        return AppTheme.bottomPlayerColor;
      case Seat.left:
        return AppTheme.leftPlayerColor;
    }
  }

  PlayerState? _playerBySeat(Seat seat) {
    for (final p in _gameState.players) {
      if (p.seat == seat) {
        return p;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    Widget content = PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        final shouldAbandon = await showDialog<bool>(
          context: context,
          barrierColor: Colors.black45,
          builder: (context) => const PauseDialog(),
        );
        if (shouldAbandon == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: TamTamBackground(
          child: SafeArea(child: _buildMatchLayout()),
        ),
      ),
    );
    if (!kReleaseMode && _devModeVisible) {
      return DevOverlay(
        gameState: _gameState,
        onForceCast: (castResult) => _performCast(castResult),
        onJumpProgress: (playerId, progress) {
          if (_isAnimating) {
            return;
          }
          setState(() {
            final players = List<PlayerState>.from(_gameState.players);
            final idx = players.indexWhere((p) => p.id == playerId);
            if (idx != -1) {
              players[idx] = players[idx].copyWith(progress: progress);
              _gameState = _gameState.copyWith(players: players);
            }
          });
        },
        child: content,
      );
    }
    return content;
  }

  Widget _buildMatchLayout() {
    final topPlayer = _playerBySeat(Seat.top);
    final bottomPlayer = _playerBySeat(Seat.bottom);
    final leftPlayer = _playerBySeat(Seat.left);
    final rightPlayer = _playerBySeat(Seat.right);
    final activeSeat = _gameState.activePlayer.seat;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
                onLongPress: () {
                  if (!kReleaseMode) {
                    setState(() => _devModeVisible = !_devModeVisible);
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Image.asset(
                    'assets/home/icon_settings.png',
                    width: 32.0,
                    height: 32.0,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Top HUD strip: seats paired per the existing (top, left) ordering,
        // now shown side-by-side together instead of pinned to opposite
        // corners -- see section 12: no seats beside the board anymore.
        _buildHudRow([
          if (topPlayer != null)
            PlayerHud(
              name: topPlayer.name,
              color: AppTheme.topPlayerColor,
              isActive: activeSeat == Seat.top,
              isBot: topPlayer.kind == PlayerKind.bot,
            ),
          if (leftPlayer != null)
            PlayerHud(
              name: leftPlayer.name,
              color: AppTheme.leftPlayerColor,
              isActive: activeSeat == Seat.left,
              isBot: leftPlayer.kind == PlayerKind.bot,
            ),
        ]),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 2.0,
              ),
              child: BoardWidget(
                gameState: _gameState,
                animatingSeat: _animatingSeat,
                animatingCoord: _animatingCoord,
              ),
            ),
          ),
        ),
        _buildHudRow([
          if (bottomPlayer != null)
            PlayerHud(
              name: bottomPlayer.name,
              color: AppTheme.bottomPlayerColor,
              isActive: activeSeat == Seat.bottom,
              isBot: bottomPlayer.kind == PlayerKind.bot,
            ),
          if (rightPlayer != null)
            PlayerHud(
              name: rightPlayer.name,
              color: AppTheme.rightPlayerColor,
              isActive: activeSeat == Seat.right,
              isBot: rightPlayer.kind == PlayerKind.bot,
            ),
        ]),
        if (_showCaptureEffect)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 400),
            builder: (context, value, child) => Opacity(
              opacity: value > 0.5 ? 2.0 - value * 2 : value * 2,
              child: child,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: const Text(
                'CAPTURE!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14.0,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ),
        if (_showExtraCast)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 400),
            builder: (context, value, child) => Opacity(
              opacity: value > 0.5 ? 2.0 - value * 2 : value * 2,
              child: child,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: AppTheme.accent,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: const Text(
                'EXTRA CAST!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14.0,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ),
        const SizedBox(height: 4.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Tray width tracks the board's own contract ratio
              // (CastTrayContract.widthRatio) against the space actually
              // available here, rather than a device-specific pixel size.
              final trayWidth =
                  constraints.maxWidth * CastTrayContract.widthRatio;
              return Align(
                child: SizedBox(
                  width: trayWidth,
                  child: CastTray(
                    lastCast: _lastCastResult,
                    onCastPressed: () => _performCast(),
                    canCast:
                        _gameState.phase == TurnPhase.waitingForCast &&
                        !_isAnimating &&
                        !_isCubeAnimating &&
                        _gameState.activePlayer.kind == PlayerKind.human,
                    activePlayerColor: _activePlayerColor(),
                    isAnimatingCubes: _isCubeAnimating,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8.0),
      ],
    );
  }

  /// Lays out up to two seat HUDs side-by-side, centered together as a
  /// pair, instead of pinned to opposite corners. Handles the 2P case
  /// (single HUD) and empty case (no HUDs, e.g. missing seat) too.
  Widget _buildHudRow(List<Widget> huds) {
    if (huds.isEmpty) {
      return const SizedBox(height: 4.0);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < huds.length; i++) ...[
            if (i > 0) const SizedBox(width: 16.0),
            huds[i],
          ],
        ],
      ),
    );
  }
}
