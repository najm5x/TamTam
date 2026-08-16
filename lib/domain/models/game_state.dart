import 'player_state.dart';
import 'rule_profile.dart';

enum TurnPhase {
  waitingForCast,
  animatingMove,
  turnFinished,
  matchFinished,
}

class GameState {
  final List<PlayerState> players;
  final int activePlayerIndex;
  final RuleProfile ruleProfile;
  final TurnPhase phase;
  final String? winnerId;
  final int extraCastsRemaining;

  const GameState({
    required this.players,
    required this.activePlayerIndex,
    required this.ruleProfile,
    required this.phase,
    this.winnerId,
    this.extraCastsRemaining = 0,
  });

  PlayerState get activePlayer => players[activePlayerIndex];

  GameState copyWith({
    List<PlayerState>? players,
    int? activePlayerIndex,
    RuleProfile? ruleProfile,
    TurnPhase? phase,
    String? winnerId,
    int? extraCastsRemaining,
  }) {
    return GameState(
      players: players ?? this.players,
      activePlayerIndex: activePlayerIndex ?? this.activePlayerIndex,
      ruleProfile: ruleProfile ?? this.ruleProfile,
      phase: phase ?? this.phase,
      winnerId: winnerId ?? this.winnerId,
      extraCastsRemaining: extraCastsRemaining ?? this.extraCastsRemaining,
    );
  }
}
