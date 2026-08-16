import 'package:flutter/material.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/game_event.dart';
import '../../domain/models/player_state.dart';
import '../../domain/models/rule_profile.dart';
import '../../domain/models/seat.dart';
import '../../domain/models/cast_result.dart';
import '../../domain/engine/tamtam_engine.dart';
import '../../domain/engine/cast_generator.dart';
import '../theme/app_theme.dart';
import '../widgets/board_widget.dart';
import '../widgets/cast_tray.dart';
import '../widgets/player_hud.dart';
import '../widgets/dev_overlay.dart';
import 'result_screen.dart';
import '../widgets/pause_dialog.dart';
import 'package:flutter/foundation.dart';

class MatchScreen extends StatefulWidget {
  final GameState? initialState;
  const MatchScreen({super.key, this.initialState});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> with TickerProviderStateMixin {
  late GameState _gameState;
  final CastGenerator _castGenerator = FairBinaryCastGenerator();
  CastResult? _lastCastResult;
  bool _devModeVisible = false;

  // Animation state
  bool _isAnimating = false;
  Seat? _animatingSeat;
  String? _animatingCoord;

  // Cube animation state
  bool _isCubeAnimating = false;

  // Capture/extra cast feedback
  bool _showCaptureEffect = false;
  bool _showExtraCast = false;

  @override
  void initState() {
    super.initState();
    _gameState = widget.initialState ?? GameState(
      players: [
        PlayerState(id: 'p1', name: 'Player 1', seat: Seat.bottom, kind: PlayerKind.human, progress: 0),
        PlayerState(id: 'p2', name: 'Player 2', seat: Seat.top, kind: PlayerKind.human, progress: 0),
      ],
      activePlayerIndex: 0,
      ruleProfile: RuleProfile.classic(),
      phase: TurnPhase.waitingForCast,
    );
    _checkBotTurn();
  }

  void _checkBotTurn() {
    if (_gameState.phase != TurnPhase.waitingForCast) return;
    final active = _gameState.activePlayer;
    if (active.kind == PlayerKind.bot) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        _performCast();
      });
    }
  }

  Duration _stepDuration(int moveLength) {
    if (moveLength <= 6) return const Duration(milliseconds: 100);
    if (moveLength <= 16) return const Duration(milliseconds: 75);
    return const Duration(milliseconds: 60);
  }

  Color _activePlayerColor() {
    final seat = _gameState.activePlayer.seat;
    switch (seat) {
      case Seat.top: return AppTheme.topPlayerColor;
      case Seat.right: return AppTheme.rightPlayerColor;
      case Seat.bottom: return AppTheme.bottomPlayerColor;
      case Seat.left: return AppTheme.leftPlayerColor;
    }
  }

  void _performCast([CastResult? forcedCast]) {
    if (_gameState.phase != TurnPhase.waitingForCast || _isAnimating || _isCubeAnimating) return;

    final castResult = forcedCast ?? _castGenerator.generate();
    final activePlayer = _gameState.activePlayer;

    // Apply engine transition atomically
    final transition = TamTamEngine.apply(_gameState, RequestCast(castResult));

    List<String>? movementPath;
    PieceCaptured? captureEvent;
    bool hasExtraCast = false;
    for (final event in transition.events) {
      if (event is PieceMovementPlanned) movementPath = event.path;
      if (event is PieceCaptured) captureEvent = event;
      if (event is ExtraCastGranted) hasExtraCast = true;
    }

    // Cube tumble animation first
    setState(() {
      _isCubeAnimating = true;
    });

    Future.delayed(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      setState(() {
        _isCubeAnimating = false;
        _lastCastResult = castResult;
      });

      // Small pause to show the result
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        if (movementPath != null && movementPath.isNotEmpty) {
          _animateMovement(
            seat: activePlayer.seat,
            path: movementPath,
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
      if (!mounted) return;
      setState(() => _animatingCoord = coord);
      await Future.delayed(duration);
    }

    if (!mounted) return;

    setState(() {
      _animatingSeat = null;
      _animatingCoord = null;
      _isAnimating = false;
      _gameState = finalState;
    });

    // Capture feedback
    if (captureEvent != null) {
      setState(() => _showCaptureEffect = true);
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      setState(() => _showCaptureEffect = false);
    }

    // Extra cast feedback
    if (hasExtraCast) {
      setState(() => _showExtraCast = true);
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() => _showExtraCast = false);
    }

    _afterMovement(hasExtraCast: hasExtraCast);
  }

  void _afterMovement({required bool hasExtraCast}) {
    if (!mounted) return;

    if (_gameState.phase == TurnPhase.turnFinished || _gameState.phase == TurnPhase.animatingMove) {
      final nextTrans = TamTamEngine.apply(_gameState, NextTurn());
      setState(() => _gameState = nextTrans.state);

      if (_gameState.phase == TurnPhase.matchFinished) {
        final winner = _gameState.players.firstWhere((p) => p.isWinner, orElse: () => _gameState.activePlayer);
        final winnerColor = _seatColor(winner.seat);
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => ResultScreen(
                winnerName: winner.name,
                winnerColor: winnerColor,
              ),
            ),
          );
        });
      } else {
        _checkBotTurn();
      }
    }
  }

  Color _seatColor(Seat seat) {
    switch (seat) {
      case Seat.top: return AppTheme.topPlayerColor;
      case Seat.right: return AppTheme.rightPlayerColor;
      case Seat.bottom: return AppTheme.bottomPlayerColor;
      case Seat.left: return AppTheme.leftPlayerColor;
    }
  }

  PlayerState? _playerBySeat(Seat seat) {
    for (final p in _gameState.players) {
      if (p.seat == seat) return p;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    Widget content = PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        final shouldAbandon = await showDialog<bool>(
          context: context,
          builder: (context) => const PauseDialog(),
        );
        if (shouldAbandon == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.surfaceBg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.pause_rounded, size: 22),
            onPressed: () async {
              final shouldAbandon = await showDialog<bool>(
                context: context,
                builder: (context) => const PauseDialog(),
              );
              if (shouldAbandon == true && mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          title: GestureDetector(
            onLongPress: () {
              if (!kReleaseMode) {
                setState(() => _devModeVisible = !_devModeVisible);
              }
            },
            child: Text(
              'TAMTAM',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 3,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.volume_up_rounded, size: 22, color: AppTheme.textSecondary),
              onPressed: () {},
            ),
          ],
        ),
        body: SafeArea(
          child: _buildMatchLayout(),
        ),
      ),
    );

    if (!kReleaseMode && _devModeVisible) {
      return DevOverlay(
        gameState: _gameState,
        onForceCast: (castResult) => _performCast(castResult),
        onJumpProgress: (playerId, progress) {
          if (_isAnimating) return;
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
    final hasSidePlayers = leftPlayer != null || rightPlayer != null;
    final activeSeat = _gameState.activePlayer.seat;

    return Column(
      children: [
        // Top player HUD
        if (topPlayer != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: PlayerHud(
              name: topPlayer.name,
              color: AppTheme.topPlayerColor,
              isActive: activeSeat == Seat.top,
              isBot: topPlayer.kind == PlayerKind.bot,
            ),
          ),

        // Board row with optional Left/Right HUDs
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                if (leftPlayer != null)
                  SizedBox(
                    width: 36,
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: PlayerHud(
                        name: leftPlayer.name,
                        color: AppTheme.leftPlayerColor,
                        isActive: activeSeat == Seat.left,
                        isBot: leftPlayer.kind == PlayerKind.bot,
                      ),
                    ),
                  ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: hasSidePlayers ? 4.0 : 8.0,
                        vertical: 4.0,
                      ),
                      child: BoardWidget(
                        gameState: _gameState,
                        animatingSeat: _animatingSeat,
                        animatingCoord: _animatingCoord,
                      ),
                    ),
                  ),
                ),
                if (rightPlayer != null)
                  SizedBox(
                    width: 36,
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: PlayerHud(
                        name: rightPlayer.name,
                        color: AppTheme.rightPlayerColor,
                        isActive: activeSeat == Seat.right,
                        isBot: rightPlayer.kind == PlayerKind.bot,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Bottom player HUD
        if (bottomPlayer != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: PlayerHud(
              name: bottomPlayer.name,
              color: AppTheme.bottomPlayerColor,
              isActive: activeSeat == Seat.bottom,
              isBot: bottomPlayer.kind == PlayerKind.bot,
            ),
          ),

        // Feedback overlays
        if (_showCaptureEffect)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 400),
            builder: (context, value, child) {
              return Opacity(
                opacity: value > 0.5 ? 2.0 - value * 2 : value * 2,
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'CAPTURE!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),

        if (_showExtraCast)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 400),
            builder: (context, value, child) {
              return Opacity(
                opacity: value > 0.5 ? 2.0 - value * 2 : value * 2,
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.accent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'EXTRA CAST!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),

        const SizedBox(height: 4),

        // Cast tray
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CastTray(
            lastCast: _lastCastResult,
            onCastPressed: _performCast,
            canCast: _gameState.phase == TurnPhase.waitingForCast &&
                !_isAnimating &&
                !_isCubeAnimating &&
                _gameState.activePlayer.kind == PlayerKind.human,
            activePlayerColor: _activePlayerColor(),
            isAnimatingCubes: _isCubeAnimating,
          ),
        ),

        const SizedBox(height: 8),
      ],
    );
  }
}
