import '../models/game_event.dart';
import '../models/game_state.dart';
import '../models/cast_result.dart';
import '../models/player_state.dart';
import '../models/seat.dart';
import '../routes/canonical_routes.dart';

abstract class GameAction {}

class RequestCast extends GameAction {
  final CastResult castResult;
  RequestCast(this.castResult);
}

class NextTurn extends GameAction {} // Called after animation / extra casts

class GameTransition {
  final GameState state;
  final List<GameEvent> events;

  const GameTransition(this.state, this.events);
}

class TamTamEngine {
  static GameTransition apply(GameState state, GameAction action) {
    if (state.phase == TurnPhase.matchFinished) {
      return GameTransition(state, []);
    }

    if (action is RequestCast) {
      if (state.phase != TurnPhase.waitingForCast) {
        return GameTransition(state, []);
      }
      return _handleCast(state, action.castResult);
    }

    if (action is NextTurn) {
      if (state.phase != TurnPhase.turnFinished && state.phase != TurnPhase.animatingMove) {
        return GameTransition(state, []);
      }
      return _advanceTurn(state);
    }

    return GameTransition(state, []);
  }

  static GameTransition _handleCast(GameState state, CastResult castResult) {
    final List<GameEvent> events = [CastResolved(castResult)];
    final activePlayer = state.activePlayer;
    final int currentProgress = activePlayer.progress;
    final int castValue = castResult.value;
    final int targetProgress = currentProgress + castValue;
    final int finishProgress = state.ruleProfile.finishProgress;

    // Check overshoot
    if (targetProgress > finishProgress) {
      events.add(const OvershootOccurred());
      events.add(TurnEnded(state.players[(state.activePlayerIndex + 1) % state.players.length].id));
      
      final nextState = state.copyWith(
        phase: TurnPhase.turnFinished,
      );
      return GameTransition(nextState, events);
    }

    // Determine path for animation
    final route = _getRouteForSeat(activePlayer.seat);
    final List<String> path = [];
    for (int p = currentProgress + 1; p <= targetProgress; p++) {
      path.add(route[p]);
      if (p == 32) {
        events.add(BoundaryCrossed(route[p]));
      }
      if (p == _getGateProgress(activePlayer.seat)) {
        events.add(GateCrossed(route[p]));
      }
    }
    events.add(PieceMovementPlanned(path));

    final targetCell = route[targetProgress];
    events.add(PieceLanded(targetCell));

    // Update active player's progress
    final updatedActivePlayer = activePlayer.copyWith(progress: targetProgress);
    
    // Check capture
    bool captured = false;
    List<PlayerState> updatedPlayers = List.of(state.players);
    updatedPlayers[state.activePlayerIndex] = updatedActivePlayer;

    if (!state.ruleProfile.safeCells.contains(targetCell)) {
      for (int i = 0; i < updatedPlayers.length; i++) {
        if (i == state.activePlayerIndex) continue;
        final opponent = updatedPlayers[i];
        final opponentRoute = _getRouteForSeat(opponent.seat);
        if (opponent.progress >= 0 && opponent.progress <= finishProgress) {
          if (opponentRoute[opponent.progress] == targetCell) {
            // Capture!
            final resetProgress = state.ruleProfile.startProgress;
            updatedPlayers[i] = opponent.copyWith(progress: resetProgress);
            events.add(PieceCaptured(opponent.id, targetCell));
            captured = true;
          }
        }
      }
    }

    int extraCasts = state.extraCastsRemaining;
    if (captured) {
      extraCasts += 1;
      events.add(const ExtraCastGranted());
    }

    // Check win
    if (targetProgress == finishProgress) {
      updatedPlayers[state.activePlayerIndex] = updatedActivePlayer.copyWith(isWinner: true);
      events.add(MatchWon(updatedActivePlayer.id));
      return GameTransition(
        state.copyWith(
          players: updatedPlayers,
          phase: TurnPhase.matchFinished,
          winnerId: updatedActivePlayer.id,
          extraCastsRemaining: 0,
        ),
        events,
      );
    }

    // Finalize state
    TurnPhase nextPhase = TurnPhase.turnFinished;
    
    // Add turn ended if no extra casts
    if (extraCasts == 0) {
      events.add(TurnEnded(updatedPlayers[(state.activePlayerIndex + 1) % updatedPlayers.length].id));
    }

    return GameTransition(
      state.copyWith(
        players: updatedPlayers,
        phase: nextPhase,
        extraCastsRemaining: extraCasts,
      ),
      events,
    );
  }

  static GameTransition _advanceTurn(GameState state) {
    if (state.extraCastsRemaining > 0) {
      return GameTransition(
        state.copyWith(
          phase: TurnPhase.waitingForCast,
          extraCastsRemaining: state.extraCastsRemaining - 1,
        ),
        [],
      );
    }

    final nextPlayerIndex = (state.activePlayerIndex + 1) % state.players.length;
    return GameTransition(
      state.copyWith(
        activePlayerIndex: nextPlayerIndex,
        phase: TurnPhase.waitingForCast,
      ),
      [],
    );
  }

  static List<String> _getRouteForSeat(Seat seat) {
    switch (seat) {
      case Seat.top:
        return CanonicalRoutes.topClassicUnified;
      case Seat.right:
        return CanonicalRoutes.rightClassicUnified;
      case Seat.bottom:
        return CanonicalRoutes.bottomClassicUnified;
      case Seat.left:
        return CanonicalRoutes.leftClassicUnified;
    }
  }

  static int _getGateProgress(Seat seat) {
    // Gate is at local index 29 of the second round.
    // In unified progress, first round is 32.
    // So gate = 32 + 29 = 61.
    return 61;
  }
}
